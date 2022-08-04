// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Main window class
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    class Window : Adw.ApplicationWindow {
        [GtkChild] unowned Adw.ButtonContent tool_button_content;
        [GtkChild] unowned Gtk.EventControllerKey search_event_controller;
        [GtkChild] unowned Gtk.ListBox search_listbox;
        [GtkChild] unowned Gtk.SearchEntry search_entry;
        [GtkChild] unowned TextPieces.Editor editor;
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
         * Window actions
         */
        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply"            , action_apply            },
            { "open-preferences" , action_open_preferences },
            { "about"            , action_about            },
            { "copy"             , action_copy             },
            { "tools-settings"   , action_tools_settings   },
            { "toggle-search"    , action_toggle_search    },
            { "save-as"          , action_save_as          },
            { "load-file"        , action_load_file        },
            { "jump-to-args"     , action_jump_to_args     }
        };

        public Window (Application application) {
            Object (
                application: application
            );
        }

        construct {
            /* Restore window geometry from settings */
            with (Application.settings) {
                default_width = get_int ("window-width");
                default_height = get_int ("window-height");
                maximized = get_boolean ("is-maximized");
            }

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
         * Close request callback
         *
         * Saves window geometry.
         */
        protected override bool close_request () {
            save_window_size ();

            return false;
        }

        /**
         * Save window size
         */
        public void save_window_size () {
            with (Application.settings) {
                set_int ("window-width", default_width);
                set_int ("window-height", default_height);
                set_boolean ("is-maximized", maximized);
            }
        }

        /**
         * Apply tool
         */
        void action_apply () {
            /* Don't apply non-existing tool */
            if (selected_tool == null)
                return;

            /* Get arguments from
               argument entries */
            var args = editor.get_arguments ();

            /* Apply tool on text */
            var result = selected_tool.apply (
                editor.get_selection (),
                args
            );

            string result_text;

            /* Send error notification
               if stderr is not null */
            if (result.error != null) {
                editor.show_message (result.error);
            }

            /* Set new text if stdout
               is not null */
            if (result.output != null) {
                result_text = result.output;
            } else {
                return;
            }

            editor.replace_selection (result_text);
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
            editor.copy_text ();
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
                    editor.save_as (file);
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
                    editor.load_from (file);
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
            editor.jump_to_args ();
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

            editor.set_arguments (selected_tool?.arguments ?? new string[0]);

            /* Update editor's top margin */
            Idle.add (() => {
                editor.update_editor_margin ();

                return Source.REMOVE;
            });
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
