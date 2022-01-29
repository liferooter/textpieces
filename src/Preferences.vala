// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces {
    /**
     * Preferences window
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Preferences.ui")]
    class Preferences : Adw.PreferencesWindow {
        [GtkChild] unowned Gtk.ListBox custom_tools_listbox;
        [GtkChild] unowned Gtk.Label font_label;
        [GtkChild] unowned Gtk.SpinButton spaces_in_tab;
        [GtkChild] unowned GtkSource.StyleSchemeChooserWidget style_scheme_chooser;

        /**
         * Preferences window actions
         */
        const ActionEntry[] ACTION_ENTRIES = {
            { "select-font", action_select_font }
        };

        /**
         * List of settings keys
         * binded to the actions
         */
        const string[] SETTINGS_ACTIONS = {
            "wrap-lines",
            "tabs-to-spaces"
        };

        public Preferences (TextPieces.Window win) {
            win.bind_property (
                "style-scheme",
                style_scheme_chooser,
                "style-scheme",
                SYNC_CREATE | BIDIRECTIONAL
            );
        }

        construct {
            /* Create actions from entries */
            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);

            insert_action_group ("prefs", action_group);

            /* Create settings actions */
            var settings_group = new SimpleActionGroup ();
            foreach (var setting in SETTINGS_ACTIONS) {
                var action = Application.settings
                    .create_action (setting);
                settings_group.add_action (action);
            }

            insert_action_group ("settings", settings_group);

            /* Bind settings to corresponding widgets */
            with (Application.settings) {
                bind (
                    "font-name",
                    font_label,
                    "label",
                    DEFAULT
                );
                bind (
                    "spaces-in-tab",
                    spaces_in_tab,
                    "value",
                    DEFAULT
                );
            }

            /* Bind list of custom tools to `custom_tools_listbox` */
            var tools = Application.tools.custom_tools;
            custom_tools_listbox.bind_model (
                tools,
                (obj) => {
                    var item = (Tool) obj;
                    var row = new Adw.ActionRow () {
                        title = item.name,
                        subtitle = item.description,
                        activatable = true
                    };
                    row.add_suffix (new Gtk.Image () {
                        icon_name = "go-next-symbolic"
                    });

                    return row;
                }
            );

            /* Don't show empty list */
            update_tools_visibility ();
            tools.items_changed.connect (update_tools_visibility);
        }

        ~Preferences () {
            /* Unbind list visibility */
            Application
                .tools
                .custom_tools
                .items_changed
                .disconnect (update_tools_visibility);
        }

        /**
         * Update tools listbox visibility
         *
         * Hide if there are no custom tools,
         * show if there are any custom tools
         */
        void update_tools_visibility () {
            custom_tools_listbox.visible
                = Application.tools.custom_tools.get_n_items () > 0;
        }

        /**
         * Select font action
         *
         * Show dialog to select
         * font for editor and
         * argument entries
         */
        void action_select_font () {
            /* Create dialog */
            var dialog = new Gtk.FontChooserDialog (_("Select font"), this) {
                modal = true,
                transient_for = this,
                font = Application.settings.get_string ("font-name"),
                level = FAMILY
            };

            /* Set font and close dialog on response */
            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.OK) {
                    Application.settings.set_string ("font-name", dialog.font_desc.get_family ());
                }

                dialog.close ();
            });

            /* Show dialog */
            dialog.present ();
        }

        /**
         * Open tool creating page
         */
        [GtkCallback]
        void add_new_tool () {
            present_subpage (new NewToolPage (this));
        }

        /**
         * Open tool settings page
         */
        [GtkCallback]
        void edit_tool (Gtk.ListBoxRow row) {
            var tool = (Tool) Application
                .tools
                .custom_tools
                .get_item (row.get_index ());
            present_subpage (new CustomToolPage (this, tool));
        }
    }
}
