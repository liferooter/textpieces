/* Window.vala
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

    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/Window.ui")]
    public class Window : Adw.ApplicationWindow {

        private const ActionEntry[] ACTION_ENTRIES = {
            { "apply", action_apply },
            { "preferences", action_preferences },
            { "about", action_about },
            { "copy", action_copy }
        };

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            // Load actions
            add_action_entries (ACTION_ENTRIES, this);

            // Set help overlay
            var builder = new Gtk.Builder.from_resource ("/com/github/liferooter/textpieces/ui/ShortcutsWindow.ui");
            var overlay = (Gtk.ShortcutsWindow) builder.get_object ("overlay");
            set_help_overlay (overlay);
        }

        void action_apply () {
            // Not Implemented Yet
            message ("ACTION APPLY");
        }

        void action_preferences () {
            var prefs = new Preferences () {
                transient_for =  this
            };
            prefs.present ();
        }

        void action_about () {
            // Not Implemented Yet
            message ("ACTION ABOUT");
        }

        void action_copy () {
            // Not Implemented Yet
            message ("ACTION COPY");
        }
    }
}
