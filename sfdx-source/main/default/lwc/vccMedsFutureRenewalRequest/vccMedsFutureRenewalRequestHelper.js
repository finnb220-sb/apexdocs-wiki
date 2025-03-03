import { datatableHelper } from 'c/utils';
// import { proxyTool } from 'c/helpersLWC';

export const sortList = datatableHelper.sortFlatList;
export const getColumn = (columns, fieldName) => columns.filter((entry) => entry.fieldName === fieldName)[0];
