function calcTableHeight(listSize, rowHeight, tableHeight, minTableHeight, maxTableHeight) {
    var bareMinimumLimit = 50; //sanity check
    var calcPixels = bareMinimumLimit + listSize * rowHeight;
    if (calcPixels <= minTableHeight) {
        tableHeight = minTableHeight;
    } else if (calcPixels > minTableHeight && calcPixels <= maxTableHeight) {
        tableHeight = calcPixels;
    } else {
        tableHeight = maxTableHeight;
    }
    return 'height: ' + tableHeight + 'px;';
}

function calcDivMaxHeight(tableHeight) {
    var divHeight = tableHeight + 100;
    return 'max-height: ' + divHeight + 'px;';
}

export { calcTableHeight, calcDivMaxHeight };
