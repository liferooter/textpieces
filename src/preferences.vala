/* preferences.vala
 *
 * Copyright 2021 Liferooter <glebsmirnov0708@gmail.com>
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

namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/preferences.ui")]
    class Preferences : Hdy.PreferencesWindow {
        [GtkChild]
        Gtk.Switch prefer_dark;
        [GtkChild]
        Gtk.Switch show_line_numbers;
        [GtkChild]
        Gtk.Switch show_grid;
        [GtkChild]
        Gtk.Switch tab_to_spaces;

        public Preferences (Gtk.Window win) {
            Object ();
            this.set_transient_for (win);


            Textpieces.Application.settings.bind ("prefer-dark",
                                                  prefer_dark,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("show-line-numbers",
                                                  show_line_numbers,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("show-grid",
                                                  show_grid,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
            Textpieces.Application.settings.bind ("tab-to-spaces",
                                                  tab_to_spaces,
                                                  "active",
                                                  SettingsBindFlags.DEFAULT);
        }
    }
}
