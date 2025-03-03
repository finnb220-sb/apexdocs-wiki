import { datatableHelper } from "c/utils";
import * as helper from "c/helpersLWC";
export const sortList = datatableHelper.sortFlatList;

const dateTimeFormat = {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    hour12: true
};

export const uniqueVals = (list) => {
    if (list?.length) {
        const result = [];

        const map = new Map();
        for (const item of list) {
            if (!map.has(item.uid)) {
                map.set(item.uid, true);
                result.push({
                    ...item
                });
            }
        }
        return result;
    }
};

// return flat list of EHRM notes
const getNotesFromAllSites = (list) => {
    const items = [];
    if (list?.length) {
        list.forEach((e) => {
            if (e?.data?.items?.length) {
                items.push(e.data.items);
            }
        });
    }
    return items.flat();
};

//
export const process = (parsedResponse) => {
    if (parsedResponse && parsedResponse?.sites) {
        const sites = parsedResponse?.sites;
        let notes = getNotesFromAllSites(sites).map((element) => {
            return { ...element, formattedDate: parseDate(element.referenceDateTime), vahcId: helper.uniqueId() };
        });

        notes = sortList([...notes], { propertyName: "formattedDate", type: "date" });

        return {
            facility: helper.groupBy(notes, "facilityName"),
            type: helper.groupBy(notes, "documentTypeName"),
            all: notes
        };
    }
};

const parseDate = (dateLiteral) => {
    try {
        const [year, month, day, hour, min, sec] = [
            dateLiteral.slice(0, 4),
            dateLiteral.slice(4, 6),
            dateLiteral.slice(6, 8),
            dateLiteral.slice(8, 10),
            dateLiteral.slice(10, 12),
            dateLiteral.slice(12, 14)
        ];

        return new Date(year, month - 1, day, hour, min, sec).toLocaleString("en-US", dateTimeFormat);
    } catch (err) {
        return "\u2014";
    }
};
