/* arg-entry.vala
 *
 * Copyright 2021 liferooter
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
 */

namespace Textpieces {
    [GtkTemplate (ui = "/com/github/liferooter/textpieces/ui/argument.ui")]
    class Argument : Gtk.Box {
        [GtkChild]
        private Gtk.Label arg_label;
        [GtkChild]
        public Gtk.Entry arg_entry;

        public Argument (string name) {
            Object (
                hexpand: true
            );
            arg_label.set_label (name);
        }

        construct {
            this.show_all ();
        }
    }
}