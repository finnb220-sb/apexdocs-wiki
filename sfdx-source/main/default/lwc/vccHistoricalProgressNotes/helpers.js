/**
 * @description updates authorName if the current author is not the first clinician in the list with an author role (CCCM-38534)
 * @param list list of progress notes
 * @returns list of progress notes with authorName updated, or an empty list if the list is null or undefined
 */
export function assignAuthor(list) {
    if (!list) {
        return [];
    }
    if (list?.length) {
        for (let index = 0; index < list.length; index++) {
            if (!Array.isArray(list[index].clinicians) || list[index].clinicians.length === 0) {
                list[index].authorName = '';
                continue;
            }
            if (list[index].clinicians[0].role === 'A' && list[index].authorName !== list[index].clinicians[0].name) {
                list[index].authorName = list[index].clinicians[0].name;
            }
        }
    }
    return list;
}
