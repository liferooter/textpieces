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
        [GtkChild] unowned TextPieces.Editor editor;
        [GtkChild] unowned Gtk.Stack content_stack;
        [GtkChild] unowned Gtk.ToggleButton tool_button;
        [GtkChild] unowned Search search;

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

                /* Save selected tool in GSettings */
                Application.settings.set_string (
                    "selected-tool",
                    value?.script ?? ""
                );

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
            { "jump-to-args"     , action_jump_to_args     },
            { "find"             , action_find             },
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

            /* Unselect tool if it's deleted */
            Application.tools.delete_tool.connect ((tool) => {
                if (tool == selected_tool)
                    selected_tool = null;
            });

            /* Initialize selected
               tool property and run
               its callback */
            var selected_tool_script = Application.settings.get_string ("selected-tool");
            var tool_found = false;

            if (selected_tool_script != "") {
                for (uint i = 0; i < Application.tools.all_tools.get_n_items (); i++) {
                    var tool = (Tool) Application.tools.all_tools.get_item (i);
                    if (tool.script == selected_tool_script) {
                        selected_tool = tool;
                        tool_found = true;
                        break;
                    }
                }

                if (!tool_found) {
                    message ("Previously selected tool is not found, so will be reset");
                    selected_tool = null;
                }
            } else {
                selected_tool = null;
            }
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
            var about_window = new Adw.AboutWindow () {
                transient_for = this,
                application = application,

                application_icon = "com.github.liferooter.textpieces",
                application_name = _("Text Pieces"),
                comments = _("Transform text without using random websites"),
                version = Config.VERSION,
                license_type = Gtk.License.GPL_3_0,

                website = "https://github.com/liferooter/textpieces",
                issue_url = "https://github.com/liferooter/textpieces/issues/new",

                artists = {_("Tobias Bernard https://tobiasbernard.com")},
                developers = {_("Gleb Smirnov <glebsmirnov0708@gmail.com>")},

                developer_name = _("Gleb Smirnov"),
                translator_credits = _("translator-credits")
            };

            about_window.present ();
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
         * Show search overlay
         */
        void action_find () {
            editor.search_bar.show_search ();
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
         * Select tool and close the search
         */
        [GtkCallback]
        void on_tool_selected (Tool tool) {
            selected_tool = tool;
            tool_button.active = false;
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
            } else {
                /* Show editor */
                content_stack.visible_child_name = "editor";
                search.reset ();
            }
        }
    }
}
