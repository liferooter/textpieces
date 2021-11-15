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
        string accel;
    }

    class Application : Adw.Application {
        public static GLib.Settings settings;

        public ToolsController tools;

        private const ActionAccel[] ACTION_ACCELS = {
            { "win.escape", "Escape" },
            { "win.apply", "<Alt>a" },
            { "win.copy", "<Alt>c" },
            { "win.preferences", "<Control>comma" },
            { "win.show-help-overlay", "<Control>question" },
            { "win.load-file", "<Control>o" },
            { "win.save-as", "<Control>s" },
            { "win.toggle-search", "<Alt>s" },
            { "win.jump-to-args", "<Alt>Return" },
            { "window.close", "<Control>q / <Control>w" },
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

            if (style_manager.system_supports_color_schemes) {
                style_manager.set_color_scheme (Adw.ColorScheme.PREFER_DARK);
                style_manager.notify["dark"].connect (dark_changed_cb);
                dark_changed_cb ();
            } else {
                var color_scheme_action = settings.create_action ("color-scheme");
                add_action (color_scheme_action);

                settings.changed.connect ((key) => {
                    if (key == "color-scheme")
                        color_scheme_changed_cb ();
                });
                color_scheme_changed_cb ();
            }

            // Setup actions
            foreach (var action_accel in ACTION_ACCELS) {
                set_accels_for_action (
                    action_accel.action,
                    action_accel.accel.split (" / ")
                );
            }

            // Create window
            var win = get_active_window ();
            if (win == null)
                win = new TextPieces.Window (this) {
                    application = this
                };
            win.present ();
        }

        void dark_changed_cb () {
            settings.set_string (
                "color-scheme",
                style_manager.dark
                    ? "dark"
                    : "light"
            );
        }

        void color_scheme_changed_cb () {
            style_manager.set_color_scheme (
                settings.get_string ("color-scheme") == "dark"
                    ? Adw.ColorScheme.FORCE_DARK
                    : Adw.ColorScheme.FORCE_LIGHT
            );
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
