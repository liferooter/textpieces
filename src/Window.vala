// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Error toast timeout, in seconds
     */
    const uint TOAST_TIMEOUT = 2;

    /**
     * Main window class
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    class Window : Adw.ApplicationWindow {
        [GtkChild] unowned Adw.ButtonContent tool_button_content;
        [GtkChild] unowned Adw.ToastOverlay toast_overlay;
        [GtkChild] unowned Gtk.Box arguments_box;
        [GtkChild] unowned Gtk.EventControllerKey search_event_controller;
        [GtkChild] unowned Gtk.ListBox search_listbox;
        [GtkChild] unowned Gtk.SearchEntry search_entry;
        [GtkChild] unowned GtkSource.View editor;
        [GtkChild] unowned Gtk.Stack content_stack;
        [GtkChild] unowned Gtk.Stack search_stack;
        [GtkChild] unowned Gtk.ToggleButton tool_button;
        [GtkChild] unowned Gtk.Viewport search_viewport;

        /**
         * Text used instead of tool name
         * when where is no tool selected
         */
        const string NO_TOOL_LABEL = _("Select tool");

        /**
         * Name of icon used
         * instead of tool icon
         * where is no tool selected
         */
        const string NO_TOOL_ICON = "applications-utilities-symbolic";

        /**
         * Tool search model
         */
        Gtk.SortListModel search_model;

        /**
         * Sorter for search results
         */
        Gtk.Sorter search_sorter;

        /**
         * Filter for search results
         */
        Gtk.Filter search_filter;

        /**
         * Selected tool
         */
        private Tool? _selected_tool;
        public Tool? selected_tool {
            get {
                return _selected_tool;
            } set {
                /* Disconnect callback frow old tool */
                if (_selected_tool != null)
                    _selected_tool.notify
                        .disconnect (tool_changed);

                /* Save new tool */
                _selected_tool = value;

                /* Connect callback to tool changes */
                if (_selected_tool != null)
                    _selected_tool.notify
                        .connect (tool_changed);

                /* Trigger tool change callback */
                tool_changed ();
            }
        }

        /**
         * CSS provider used to set editor font
         */
        Gtk.CssProvider editor_font_css_provider = new Gtk.CssProvider ();

        /**
         * Editor font
         */
        public string editor_font {
            set {
                editor_font_css_provider.load_from_data ("""
                    .monospace {
                        font-family: %s;
                    }
                """.printf (value).data);
            }
        }

        /**
         * CSS provider used to set style scheme
         */
        Gtk.CssProvider style_scheme_css_provider = new Gtk.CssProvider ();

        /**
         * Style scheme
         */
        public GtkSource.StyleScheme style_scheme {
            set {
                _style_scheme = value;

                /* Apply style scheme to the app */
                var is_dark = Recoloring.is_scheme_dark (value);
                Adw.StyleManager.get_default ()
                    .color_scheme = is_dark
                        ? Adw.ColorScheme.FORCE_DARK
                        : Adw.ColorScheme.FORCE_LIGHT;
                style_scheme_css_provider.load_from_data (
                    Recoloring.generate_css (value).data
                );

                notify_property ("style-scheme-id");
            } get {
                return _style_scheme;
            }
        }
        private GtkSource.StyleScheme _style_scheme;


        /**
         * Style scheme id
         */
        public string style_scheme_id {
            get {
                return style_scheme.id;
            } set {
                style_scheme = GtkSource.StyleSchemeManager
                    .get_default ()
                    .get_scheme (value);
            }
        }

        /**
         * Whether to wrap lines
         */
        public bool wrap_lines {
            set {
                editor.wrap_mode = value
                    ? Gtk.WrapMode.WORD_CHAR
                    : Gtk.WrapMode.NONE;
            }
        }

        /**
         * Window actions
         */
        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply", action_apply },
            { "open-preferences", action_open_preferences },
            { "about", action_about },
            { "copy", action_copy },
            { "tools-settings", action_tools_settings },
            { "toggle-search", action_toggle_search },
            { "save-as", action_save_as },
            { "load-file", action_load_file },
            { "jump-to-args", action_jump_to_args }
        };

        public Window (Application application) {
            Object (
                application: application
            );
        }

        construct {
            /* Bind some values to settings */
            with (Application.settings) {
                bind ("tabs-to-spaces", editor, "insert-spaces-instead-of-tabs", GET);
                bind ("spaces-in-tab",  editor, "tab-width",                     GET);
                bind ("font-name",      this,   "editor-font",                   GET);
                bind ("wrap-lines",     this,   "wrap-lines",                    GET);
            }

            /* Add style provider with editor font */
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                editor_font_css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            /* Setup style scheme */
            Application.settings.bind (
                "style-scheme",
                this,
                "style-scheme-id",
                DEFAULT
            );
            Gtk.StyleContext.add_provider_for_display (
                Gdk.Display.get_default (),
                style_scheme_css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_USER
            );

            /* Bind editor style scheme */
            this.bind_property (
                "style-scheme",
                editor.buffer,
                "style-scheme",
                SYNC_CREATE
            );

            /* Save window size between launches */
            Application.settings.bind (
                "window-width",
                this,
                "default-width",
                DEFAULT
            );
            Application.settings.bind (
                "window-height",
                this,
                "default-height",
                DEFAULT
            );
            Application.settings.bind (
                "is-maximized",
                this,
                "is-maximized",
                DEFAULT
            );

            /* Load actions */
            add_action_entries (ACTION_ENTRIES, this);

            /* Create sorter for search results */
            search_sorter = new Gtk.CustomSorter (
                (a, b) => Search.tool_sort_func ((Tool) a, (Tool) b, search_entry.text)
            );

            /* Create filter for search results */
            search_filter = new Gtk.CustomFilter (
                (tool) => Search.tool_filter_func ((Tool) tool, search_entry.text)
            );

            /* Create model for search results */
            search_model = new Gtk.SortListModel (
                new Gtk.FilterListModel (
                    Application.tools.all_tools,
                    search_filter
                ),
                search_sorter
            );

            /* Bind the model to list box */
            search_listbox.bind_model (
                search_model,
                build_list_row
            );

            /* Unselect tool if it's deleted */
            Application.tools.delete_tool.connect ((tool) => {
                if (tool == selected_tool)
                    selected_tool = null;
            });

            /* Initialize selected
               tool property and run
               its callback */
            selected_tool = null;
        }

        /**
         * Apply tool
         */
        void action_apply () {
            /* Don't apply non-existing tool */
            if (selected_tool == null)
                return;

            var buffer = editor.buffer;
            var has_selection = buffer.has_selection;
            Gtk.TextIter start, end;

            /* If some text selected, get selection,
               otherwise get all text */
            if (has_selection)
                buffer.get_selection_bounds (out start, out end);
            else
                buffer.get_bounds (out start, out end);

            /* Save selection start */
            var start_offset = start.get_offset ();

            /* Get arguments from
               argument entries */
            string[] args = {};
            var children = arguments_box.observe_children ();
            for (uint i = 0; i < children.get_n_items (); i++)
                args += ((Gtk.Entry) children.get_item (i)).text;

            /* Apply tool on text */
            var result = selected_tool.apply (
                buffer.get_text (start, end, false),
                args
            );

            string result_text;

            /* Send error notification
               if stderr is not null */
            if (result.error != null) {
                show_toast (result.error);
            }

            /* Set new text if stdout
               is not null */
            if (result.output != null) {
                result_text = result.output;
            } else {
                return;
            }

            var result_text_len = result_text.char_count ();

            buffer.begin_user_action ();

            /* Replace old text with new text */
            buffer.@delete (ref start, ref end);
            buffer.insert (ref start, result_text, -1);

            buffer.end_user_action ();

            if (has_selection) {
                /* Restore selection */
                buffer.get_iter_at_offset (
                    out start,
                    start_offset
                );
                buffer.get_iter_at_offset (
                    out end,
                    start_offset + result_text_len
                );
                buffer.select_range (start, end);
            } else {
                /* Place cursor to the start */
                buffer.get_start_iter (out start);
                buffer.place_cursor (start);
                editor.vadjustment.value = editor.top_margin;
            }
        }

        /**
         * Open preferences
         */
        void action_open_preferences () {
            /* Create preferences window */
            var prefs = new Preferences (this) {
                transient_for = this,
                /* Pass application to the window
                   to get application's shortcuts */
                application = application
            };
            prefs.present ();
        }

        /**
         * Open custom tools settings
         */
         void action_tools_settings () {
            var prefs = new Preferences (this) {
                transient_for = this,
                application = application,
                visible_page_name = "custom-tools"
            };
            prefs.present ();
        }

        /**
         * Show about dialog
         */
        void action_about () {
            string[] AUTHORS = {_("Gleb Smirnov <glebsmirnov0708@gmail.com>")};

            string[] ARTISTS = {"Tobias Bernard https://tobiasbernard.com",
                                _("Gleb Smirnov <glebsmirnov0708@gmail.com>")};

            Gtk.show_about_dialog (
                this,
                "program-name", _("Text Pieces"),
                "logo-icon-name", "com.github.liferooter.textpieces",
                "comments", _("Transform text without using random websites"),
                "version", Config.VERSION,
                "license-type", Gtk.License.GPL_3_0,
                "website", "https://github.com/liferooter/textpieces",
                "artists", ARTISTS,
                "authors", AUTHORS,
                "translator-credits", _("translator-credits"),
                null
            );
        }

        /**
         * Toggle search
         */
         void action_toggle_search () {
            tool_button.active = !tool_button.active;
        }

        /**
         * Copy all text from the
         * editor to clipboard
         */
        void action_copy () {
            Gdk.Display.get_default ()
                       .get_clipboard ()
                       .set_text (editor.buffer.text);
            show_toast (_("Text is copied to clipboard"));
        }

        /**
         * Save editor content to file
         */
        void action_save_as () {
            /* Create file chooser dialog */
            var file_chooser = new Gtk.FileChooserNative (
                _("Save to File"),
                this,
                SAVE,
                null,
                null
            ) {
                transient_for = this,
                modal = true
            };

            file_chooser.response.connect (() => {
                /* Get selected file */
                var file = file_chooser.get_file ();
                if (file == null)
                    return;

                try {
                    /* Try to save text to file */
                    FileUtils.set_contents (
                        file.get_path (),
                        editor.buffer.text
                    );
                } catch (FileError e) {
                    /* Show error dialog if error occurs */
                    var dialog = new Gtk.MessageDialog (
                        this,
                        MODAL | DESTROY_WITH_PARENT,
                        WARNING,
                        CLOSE,
                        _("Can't save to file: %s"),
                        e.message
                    );
                    dialog.response.connect (dialog.destroy);
                    dialog.show ();
                }
            });
            file_chooser.show ();
        }

        /**
         * Load editor content from file
         */
        void action_load_file () {
            /* Create file chooser dialog */
            var file_chooser = new Gtk.FileChooserNative (
                _("Load from File"),
                this,
                OPEN,
                null,
                null
            ) {
                transient_for = this,
                modal = true
            };

            file_chooser.response.connect (() => {
                /* Get selected file */
                var file = file_chooser.get_file ();
                if (file == null)
                    return;

                try {
                    /* Try to load text from file */
                    string text;

                    FileUtils.get_contents (
                        file.get_path (),
                        out text
                    );

                    editor.buffer.text = text;
                } catch (FileError e) {
                    /* Show error dialog if error occurs */
                    var dialog = new Gtk.MessageDialog (
                        this,
                        MODAL | DESTROY_WITH_PARENT,
                        WARNING,
                        CLOSE,
                        _("Can't load from file: %s"),
                        e.message
                    );
                    dialog.response.connect (dialog.destroy);
                    dialog.show ();
                }
            });
            file_chooser.show ();
        }

        /**
         * Move focus to the first arguments entry
         */
        void action_jump_to_args () {
            if (arguments_box.visible)
                ((Gtk.Widget) arguments_box.observe_children ().get_item (0))
                    .grab_focus ();
        }

        /**
         * Tool change callback
         *
         * Set tool button's
         * label and icon
         */
        void tool_changed () {
            /* Update tool button */
            with (tool_button_content) {
                label = selected_tool?.name
                    ?? NO_TOOL_LABEL;
                icon_name = selected_tool?.icon
                    ?? NO_TOOL_ICON;
            }

            /* Disable applying if there are no tool */
            ((SimpleAction) lookup_action ("apply"))
                .set_enabled (selected_tool != null);

            /* Remove old tool arguments */
            var children = arguments_box.observe_children ();
            for (int i = (int) children.get_n_items () - 1; i >= 0; i--)
                arguments_box.remove ((Gtk.Widget) children.get_item (i));

            /* Get arguments number */
            var n_args = selected_tool?.arguments?.length ?? 0;

            /* Don't show arguments box
               if there are no arguments */
            arguments_box.visible = n_args > 0;

            /* Add argument entries */
            for (var i = 0; i < n_args; i++) {
                /* Create argument entry */
                var entry = new Gtk.Entry () {
                    placeholder_text = selected_tool.arguments[i],
                };

                /* Make it monospace */
                entry.add_css_class ("monospace");

                /* Select next on press Return */
                entry.activate.connect (() => {
                    move_focus (TAB_FORWARD);
                });

                /* Add entry to the box */
                arguments_box.append (entry);
            }

            /* Update editor's top margin */
            Idle.add (() => {
                update_editor_margin ();

                return Source.REMOVE;
            });
        }

        /**
         * Show message in toast
         */
        void show_toast (string text) {
            toast_overlay.add_toast (new Adw.Toast (text) {
                priority = HIGH,
                timeout = TOAST_TIMEOUT,
            });
        }

        /**
         * Update editor's top margin
         */
        bool update_editor_margin () {
            /* Calculate new margin */
            Graphene.Rect bounds;
            assert (arguments_box.compute_bounds (this, out bounds));

            var old_margin = editor.top_margin;
            var new_margin = arguments_box.visible
                ? (int) Math.ceil (bounds.get_height ())
                : 6;

            /* Set margin */
            editor.top_margin = new_margin;

            /* Restore scroll position */
            editor.vadjustment.value = double.max(editor.vadjustment.value - old_margin + new_margin, 0);

            return Source.REMOVE;
        }

        /**
         * Update search state
         */
        [GtkCallback]
        void update_search_results () {
            /* Invalidate search sorter and filter */
            search_sorter.changed (DIFFERENT);
            search_filter.changed (DIFFERENT);

            /* Show placeholder if
               there are no tools found */
            search_stack.set_visible_child_name (
                search_model.get_n_items () == 0
                    ? "placeholder"
                    : "search"
            );
        }

        /**
         * Process key pressed in search entry
         *
         * Move focus to the first search result
         * if `Gdk.Key.Down` is pressed
         *
         * @param keyval    pressed key value
         * @param keycode   pressed key code
         * @param modifiers pressed modifiers
         *
         * @returnif whether the key press was handled
         */
        [GtkCallback]
        bool on_search_entry_key (uint keyval,
                                  uint keycode,
                                  Gdk.ModifierType modifiers) {
            switch (keyval) {
                case (Gdk.Key.Down):
                case (Gdk.Key.Up):
                    /* Move focus to listbox */
                    search_entry.move_focus (TAB_FORWARD);
                    /* Forward event to listbox */
                    search_event_controller.forward (search_listbox);
                    /* Grab focus back when done */
                    search_entry.grab_focus ();

                    return true;
                default:
                    return false;
            }
        }

        /**
         * Activate selected tool row
         */
        [GtkCallback]
        void on_search_activated () {
            var row = search_listbox.get_selected_row ()
                   ?? search_listbox.get_row_at_index (0);
            if (row != null)
                search_listbox.row_activated  (row);
        }

        /**
         * Select tool from row and stop search
         *
         * @param row activated row
         */
        [GtkCallback]
        void on_row_activated (Gtk.ListBoxRow row) {
            var tool = (Tool) search_model.get_item (row.get_index ());
            selected_tool = tool;
            search_entry.stop_search ();
        }

        /**
         * Change application state
         * according to new search state
         */
        [GtkCallback]
        void on_search_toggled () {
            if (tool_button.active) {
                /* Show search */
                content_stack.visible_child_name = "search";
                /* Scroll search to the top */
                search_viewport.vadjustment.set_value (0);
                /* Select the first row */
                var row = search_listbox.get_row_at_index (0);
                search_listbox.select_row (row);
            } else {
                /* Show editor */
                content_stack.visible_child_name = "editor";
            }
        }
    }
}
