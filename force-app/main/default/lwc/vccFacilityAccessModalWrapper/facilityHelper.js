/**
 * Created by abaddon on 11/14/23.
 */

function getLastChildOfTree(rootElement) {
    if (rootElement instanceof HTMLElement) {
        if (rootElement?.children?.length) {
            return getLastChildOfTree(rootElement?.lastChild);
        }
        return rootElement;
    }
    return null;
}

function recursiveClimb(element, forEach) {
    if (typeof forEach === "function" && element instanceof HTMLElement) {
        forEach(element);
        if (element?.parentNode) {
            return recursiveClimb(element.parentNode, forEach);
        }
        if (element?.host) {
            return recursiveClimb(element.host, forEach);
        }
    }
    return null;
}

export { getLastChildOfTree, recursiveClimb };
