/* Preferences.vala
 *
 * Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */


namespace TextPieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Preferences.ui")]
    class Preferences : Adw.PreferencesWindow {

        static Settings settings;

        [GtkChild] unowned Gtk.ListBox custom_tools_listbox;
        [GtkChild] unowned Gtk.Label font_label;
        [GtkChild] unowned Gtk.SpinButton spaces_in_tab;

        const ActionEntry[] ACTION_ENTRIES = {
            { "select-font", action_select_font }
        };

        const string[] SETTINGS_ACTIONS = {
            "wrap-lines",
            "tabs-to-spaces",
            "color-scheme"
        };

        static construct {
            settings = new GLib.Settings ("com.github.liferooter.textpieces");
        }

        construct {

            Idle.add (setup_tools);

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (ACTION_ENTRIES, this);
            insert_action_group ("prefs", action_group);

            var settings_group = new SimpleActionGroup ();
            foreach (var setting in SETTINGS_ACTIONS) {
                var action = settings.create_action (setting);
                settings_group.add_action (action);
            }
            insert_action_group ("settings", settings_group);

            settings.bind (
                "font-name",
                font_label,
                "label",
                DEFAULT
            );

            spaces_in_tab.adjustment = new Gtk.Adjustment (
                1,  // Value
                1,  // Floor
                21, // Ceil
                1,  // Step
                0,  // Nothing
                0   // Nothing
            );

            settings.bind (
                "spaces-in-tab",
                spaces_in_tab,
                "value",
                DEFAULT
            );
        }

        public bool setup_tools () {
            /* Bind list of custom tools to `custom_tools_listbox` */
            var tools = ((TextPieces.Application) application).tools.custom_tools;
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

            /* Open tool subpage when tool is selected */
            custom_tools_listbox.row_activated.connect ((row) => {
                var tool = (Tool) tools.get_item (row.get_index ());
                present_subpage (new CustomToolPage (this, tool));
            });

            /* Don't show empty list */
            custom_tools_listbox.visible = tools.get_n_items () > 0;
            tools.items_changed.connect (() => {
                custom_tools_listbox.visible = tools.get_n_items () > 0;
            });

            return Source.REMOVE;
        }

        public void action_select_font () {
            var dialog = new Gtk.FontChooserDialog (_("Select font"), this) {
                modal = true,
                transient_for = this,
                font = settings.get_string ("font-name"),
                level = FAMILY
            };

            dialog.response.connect ((res) => {
                if (res == Gtk.ResponseType.OK) {
                    settings.set_string ("font-name", dialog.font_desc.get_family ());
                }

                dialog.close ();
            });

            dialog.present ();
        }

        [GtkCallback]
        public void add_new_tool () {
            var page = new NewToolPage (this);
            present_subpage (page);
        }
    }
}
