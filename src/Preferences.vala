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

        int _expanded_row = -1;
        int expanded_row { get {
            return _expanded_row;
        } set {
            var last_expanded = _expanded_row;
            _expanded_row = value;
            if (last_expanded != -1) {
                (
                    (Adw.ExpanderRow)
                    custom_tools_listbox
                        .observe_children ()
                        .get_item (last_expanded)
                ).set_expanded (false);
            }
        }}

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

            Idle.add (setup_tools);
        }

        public bool setup_tools () {

            var tools = ((TextPieces.Application) application).tools;
            var custom_tools = tools.custom_tools;

            for (int i = 0; i < custom_tools.get_n_items (); i++)
                custom_tools_listbox.append (build_custom_tool_row (custom_tools.get_item (i)));


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

            custom_tools_listbox.row_activated.connect ((activated_row) => {
                if (activated_row != row)
                    return;

                var dialog = new NewToolDialog () {
                    transient_for = this,
                    preferences = this,
                    tools = tools
                };

                dialog.present ();
            });

            custom_tools_listbox.append (row);

            return Source.REMOVE;
        }

        public void add_tool (Tool tool) {
            custom_tools_listbox.insert (
                build_custom_tool_row (tool),
                (int) custom_tools_listbox
                        .observe_children ()
                        .get_n_items ()
                        - 1
            );
        }

        Gtk.Widget build_custom_tool_row (Object item) {
            Tool tool = (Tool) item;
            var widget = new CustomToolRow (
                tool,
                ((TextPieces.Application) application).tools
            ) {
                window = this
            };

            //  widget.bind_property (
            //      "expanded", this,
            //      "expanded-row", BindingFlags.BIDIRECTIONAL,
            //      to_expanded_row, from_expanded_row
            //  );
            widget.notify["expanded"].connect (() => {
                if (widget.expanded == true)
                    expanded_row = widget.get_index ();
                else if (expanded_row == widget.get_index ())
                    expanded_row = -1;
            });

            return widget;
        }
    }
}
