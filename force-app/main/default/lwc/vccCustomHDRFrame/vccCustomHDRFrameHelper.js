/* eslint-disable dot-notation */
import { datatableHelper } from 'c/utils';

export const sortList = datatableHelper.sortFlatList;
export const getColumn = (columns, fieldName) => columns.filter((entry) => entry['fieldName'] === fieldName)[0];
