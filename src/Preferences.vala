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

        [GtkChild]
        unowned Gtk.ListBox custom_tools_listbox;

        public int expanded_row { get; set; default = -1; }

        private const string[] PREF_ACTIONS = {
            "dark-theme"
        };

        construct {
            var action_group = new SimpleActionGroup ();
            foreach (var pref in PREF_ACTIONS) {
                action_group.add_action (
                    TextPieces.Application.settings.create_action (pref)
                );
            }
            insert_action_group ("prefs", action_group);
        }

        public void setup_tools () {

            var tools = ((TextPieces.Application) application).tools.custom_tools;

            for (int i = 0; i < tools.get_n_items (); i++)
                custom_tools_listbox.append (build_custom_tool_row (tools.get_item (i)));


            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8) {
                halign = Gtk.Align.CENTER,
                margin_top = 12,
                margin_bottom = 12
            };
            label_box.append (
                new Gtk.Image () {
                    icon_name = "list-add-symbolic"
                }
            );
            label_box.append (
                new Gtk.Label (_("Add new tool"))
            );

            var row = new Gtk.ListBoxRow () {
                child = label_box
            };

            custom_tools_listbox.append (row);
        }

       /*
        * Convert `expanded_row` to row's `expanded`.
        * `b`       - binding object
        * `from`    - Value with integer, value of `expanded_row`
        * `to`      - Value with boolean, value of `expanded`
        */
        bool from_expanded_row (Binding b, Value from, ref Value to) {
            var tool_row = (CustomToolRow) b.source;
            to.set_boolean (tool_row.get_index () == from.get_int ());
            return true;
        }

        /*
        * Convert row's `expanded` to `expanded_row`.
        * `b`       - binding object
        * `from`    - Value with boolean, value of `expanded`
        * `to`      - Value with integer, value of `expanded_row`
        */
        bool to_expanded_row (Binding b, Value from, ref Value to) {
            var tool_row = (CustomToolRow) b.source;
            if (tool_row.get_index () == to.get_int ()
                || !from.get_boolean ()) {
                to.set_int (-1);
            } else if (from.get_boolean ()) {
                to.set_int (tool_row.get_index ());
            }

            return true;
        }

        Gtk.Widget build_custom_tool_row (Object item) {
            Tool tool = (Tool) item;
            var widget = new CustomToolRow (
                tool,
                ((TextPieces.Application) application).tools
            );

            widget.bind_property (
                "expanded", this,
                "expanded-row", BindingFlags.BIDIRECTIONAL,
                to_expanded_row, from_expanded_row
            );

            return widget;
        }
    }
}
