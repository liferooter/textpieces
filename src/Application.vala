/* Application.vala
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

    struct ActionAccel {
        string action;
        string[] accels;
    }

    class Application : Adw.Application {
        public static GLib.Settings settings;

        public ToolsController tools;

        private static ActionEntry[] ACTION_ENTRIES = {
            { "quit", quit }
        };

        private static ActionAccel[] ACTION_ACCELS = {
            { "win.escape", {"Escape"} },
            { "win.apply", {"<Control>Return"} },
            { "win.copy", {"<Control><Shift>c"} },
            { "win.preferences", {"<Control>comma"} },
            { "win.show-help-overlay", {"<Control>question"} },
            { "win.load-file", {"<Control>o"} },
            { "win.save-as", {"<Control>s"} },
            { "win.toggle-search", {"<Control>f"} },
            { "win.jump-to-args", {"<Control>e"} },
            { "window.close", {"<Control>w"} },
            { "app.quit", {"<Control>q"} }
        };

        public Application () {
            Object (
                flags: ApplicationFlags.FLAGS_NONE,
                application_id: "com.github.liferooter.textpieces"
            );
        }

        static construct {
            settings = new GLib.Settings ("com.github.liferooter.textpieces");
        }

        protected override void activate () {
            tools = new ToolsController ();

            // Initialize libs
            Gtk.Sourceinit ();

            // Setup color scheme
            settings.changed.connect ((key) => {
                if (key == "color-scheme")
                    color_scheme_changed_cb ();
            });
            color_scheme_changed_cb ();

            // Setup actions
            add_action_entries (ACTION_ENTRIES, this);
            foreach (var action_accel in ACTION_ACCELS) {
                set_accels_for_action (
                    action_accel.action,
                    action_accel.accels
                );
            }

            // Create window
            var win = get_active_window ();
            if (win == null)
                win = new TextPieces.Window (this) {
                    application = this
                };

            // Bind settings
            settings.bind ("font-name", win, "editor-font", DEFAULT);
            settings.bind ("wrap-lines", win, "wrap-lines", DEFAULT);

            win.present ();
        }

        void color_scheme_changed_cb () {
            switch (settings.get_string ("color-scheme")) {
            case "dark":
                style_manager.color_scheme = FORCE_DARK;
                break;
            case "light":
                style_manager.color_scheme = FORCE_LIGHT;
                break;
            case "system-default":
                style_manager.color_scheme = PREFER_LIGHT;
                break;
            }
        }

        public static int main (string[] args) {
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
            Intl.textdomain (Config.GETTEXT_PACKAGE);

            var app = new TextPieces.Application ();
            return app.run (args);
        }
    }
}
