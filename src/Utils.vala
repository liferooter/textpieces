/* Utils.vala
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


namespace TextPieces.Utils {
    public async void open_file (File file, Gtk.Window? window = null) {

        var is_successful = true;

        try {
            is_successful = yield AppInfo.launch_default_for_uri_async (
                file.get_uri (),
                null,
                null
            );
        } catch (Error e) {
            show_error_dialog (e.message, window);
        }

        if (!is_successful)
            show_error_dialog ("Unknown error", window);
    }

    void show_error_dialog (string msg, Gtk.Window? window) {
        critical (@"Can't open file: $msg");
        if (window != null) {
            var dialog = new Gtk.MessageDialog (
                window,
                MODAL | DESTROY_WITH_PARENT,
                ERROR,
                CLOSE,
                ""
            ) {
                text = _("Oops..."),
                secondary_text = _("Can't open script file")
            };
            dialog.response.connect (() => dialog.close ());
            dialog.present ();
        }
    }
}