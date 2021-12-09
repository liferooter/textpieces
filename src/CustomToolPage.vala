/* CustomToolPage.vala
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
    /**
     * Custom tool settings page
     */
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/CustomToolPage.ui")]
    class CustomToolPage : Gtk.Box {
        [GtkChild] unowned ToolSettings tool_settings;

        /**
         * Tool which this settings is of
         */
        public Tool tool { get; construct; }

        /**
         * Parent preferences window
         */
        public Preferences prefs { get; construct; }

        public CustomToolPage (Preferences prefs, Tool tool) {
            Object (
                tool: tool,
                prefs: prefs
            );
        }

        /**
         * Unmap signal override used to
         * save changes when page is closed
         *
         * It's called when page is no
         * longer visible
         */
        public override void unmap () {
            base.unmap ();

            var custom_tools = Application.tools.custom_tools;

            /* Find tool index */
            uint pos;
            custom_tools.find (tool, out pos);

            /* Trigger tools update
               to apply changes */
            custom_tools.items_changed (pos, 1, 1);

            /* Save changes */
            Application.tools.commit.begin ((obj, res) => {
                try {
                    Application.tools.commit.end (res);
                } catch (Error e) {
                    critical ("Can't commit tools: %s", e.message);
                    prefs.add_toast (new Adw.Toast (
                        ("Error occured: %s").printf (e.message)
                    ));
                }
            });
        }

        construct {
            tool_settings.set_tool (tool);
            tool_settings.window = prefs;
        }

        /**
         * Go back and close the page
         */
        [GtkCallback]
        void go_back () {
            prefs.close_subpage ();
        }

        /**
         * Delete tool
         */
        [GtkCallback]
        void delete_tool () {
            Application.tools.delete_tool (tool);
        }
    }
}
