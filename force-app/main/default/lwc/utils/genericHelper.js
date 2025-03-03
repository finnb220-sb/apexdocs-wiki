export const uniqueId = () => {
    return Date.now() + "::" + Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
};
