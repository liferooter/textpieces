/* CustomTool.vala
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
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/CustomToolPage.ui")]
    class CustomToolPage : Gtk.Box {
        [GtkChild] unowned ToolSettings tool_settings;

        public Tool tool { get; construct; }
        public Preferences prefs { get; construct; }

        public CustomToolPage (Preferences prefs, Tool tool) {
            Object (
                tool: tool,
                prefs: prefs
            );
        }

        ~CustomToolPage () {
            var app = prefs.application as Application;
            var custom_tools = app.tools.custom_tools;

            /* Trigger tools update
               to apply changes */
            custom_tools.items_changed (
                0,
                custom_tools.get_n_items (),
                custom_tools.get_n_items ()
            );

            /* Save changes */
            app.tools.dump_custom_tools ();
        }

        construct {
            tool_settings.set_tool (tool);
            tool_settings.window = prefs;
        }

        [GtkCallback]
        void go_back () {
            prefs.close_subpage ();
        }

        [GtkCallback]
        void delete_tool () {
            var app = prefs.application as Application;
            var tools = app.tools.custom_tools;

            uint pos;
            if (tools.find (tool, out pos))
                tools.remove (pos);

            go_back ();
        }
    }
}
