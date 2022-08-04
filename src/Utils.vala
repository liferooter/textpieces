// Copyright 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

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
