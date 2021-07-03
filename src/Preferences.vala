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

            custom_tools_listbox.bind_model (
                ((TextPieces.Application) application).tools.custom_tools,
                build_custom_tool_row
            );
        }

        Gtk.Widget build_custom_tool_row (Object item) {
            Tool tool = (Tool) item;
            var widget = new CustomToolRow (
                tool,
                ((TextPieces.Application) application).tools
            );

            return widget;
        }
    }
}
