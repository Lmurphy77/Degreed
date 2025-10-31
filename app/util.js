export function execOnce(fn) {
    let p = null;
    return async () => {
        if (!p) p = fn();
        return p;
    };
}
