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
    /**
     * Create directory if not exists
     *
     * @param dir directory to ensure
     */
    public async void ensure_directory_exists (File dir)
            throws Error {
        /* Get parent directory */
        var parent_dir = dir.get_parent ();

        /* Create parent directory
           if not exists */
        if (!parent_dir.query_exists ())
            yield ensure_directory_exists (parent_dir);

        /* Create target directory
           if not exists */
        if (!dir.query_exists ())
            yield dir.make_directory_async ();
    }
}