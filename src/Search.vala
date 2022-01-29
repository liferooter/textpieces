// SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
//
// SPDX-License-Identifier: GPL-3.0-or-later

namespace TextPieces.Search {
    /**
     * Compare tools by search irrelevance
     *
     * Less relevant tool should be
     * larger than more relevant
     * to be below more relevant tool
     * in search results. If tools are
     * equal, compare tools' names.
     *
     * @param a     one tool
     * @param b     another tool
     * @param query search query
     *
     * @return zero if tools are equal, positive if `a` is larger, negative otherwise
     */
    public int tool_sort_func (Tool a, Tool b, string query) {
        var res = calculate_irrelevance (a, query)
                - calculate_irrelevance (b, query);
        if (res == 0)
            return strcmp (a.translated_name, b.translated_name);
        return res;
    }

    /**
     * Functions used to filter tools by search relevance
     *
     * Don't show tool if its irrelevance is infinite
     *
     * @param tool  the tool
     * @param query search query
     *
     * @return whether to show tool in search results
     */
    public bool tool_filter_func (Tool tool, string query) {
        return calculate_irrelevance (tool, query) != int.MAX;
    }

    /**
     * Calculate tool irrelevance
     *
     * This method is used to filter
     * and sort search results
     *
     * @param tool  the tool
     * @param query search query
     *
     * @return tool's search irrelevance
     */
    int calculate_irrelevance (Tool tool, string query) {
        /* Get case-independent form of search query */
        var casefolded_query = query.casefold ();

        return int.min (
            /* Calculate non-translated tool's irrelevance */
            calculate_irrelevance_for_fields ({
                tool.name       .casefold (),
                tool.description.casefold ()
            }, casefolded_query),
            /* Calculate translated tool's irrelevance */
            calculate_irrelevance_for_fields ({
                tool.translated_name       .casefold (),
                tool.translated_description.casefold ()
            }, casefolded_query)
        );
    }

    /**
     * Calculate fields' irrelevance
     *
     * This method gets list of fields
     * and search query and returns fields'
     * search irrelevance. The alghorythm is as follows:
     *
     * 1. If query is empty string, algorythm finishes,
     *    irrelevance is zero. It's used to fallback
     *    to alphabetical sort.
     * 2. At the start of the alghorythm irrelevance
     *    is equals to zero
     * 3. Query is divided into words, called terms
     * 4. Algorythm iterates over terms
     * 5. I search for term in fields, from the first
     *    field to the last field
     * 6. If term is not found, algorythm finishes,
     *    irrelevance is infinite
     * 7. If term is found in the field, increase
     *    irrelevance by the difference from the index of
     *    the match start and then cut out part of field
     *    from the start of field to the end of match
     * 8. At the end of the algorythm, increase
     *    irrelevance by sum of lengths of first fields
     *    which don't contain any terms
     *
     * @param fields list of the fields
     * @param query  search query
     *
     * @return tool's search irrelevance
     */
    int calculate_irrelevance_for_fields (string[] fields, string query) {
        /* If query is empty, return zero */
        if (query == "")
            return 0;

        /* Split query to terms */
        var terms = query.split (" ");

        /* Create array of field begginings.
           It's used to easily cut fields as said
           in the algorythm */
        var field_beginning = new int[fields.length];

        /* Initial irrelevance is zero */
        var irrelevance = 0;

        /* Iterate over terms */
        foreach (var term in terms) {
            /* Find first field containing the term */
            var matching_field = 0;
            var match = 0;

            while (matching_field < fields.length
                   && (match = fields[matching_field].index_of (term, field_beginning[matching_field])) == -1) {
                matching_field++;
            }

            /* If there are no such field,
               return infinity */
            if (match == -1)
                return int.MAX;

            /* Increase irrelevance by
               match beginning index */
            irrelevance += match - field_beginning[matching_field];

            /* Cut the field */
            field_beginning[matching_field] = match + term.length;
        }

        /* Increase irrelevance by sum of
           lengths of first non-matched fields */
        for (var i = 0; i < field_beginning.length && field_beginning[i] == 0; i++)
            irrelevance += fields[i].length;

        /* Return the result */
        return irrelevance;
    }
}