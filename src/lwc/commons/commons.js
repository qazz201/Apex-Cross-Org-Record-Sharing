export function isEmptyString(value) {
    if (value === undefined || value === null) {
        return true;
    }
    return isString(value) && !value.trim();
}

export function isEmptyArray(arr) {
    return !(Array.isArray(arr) && arr.length);
}

export function isString(value) {
    return typeof value === 'string' || value instanceof String;
}

export function debounce(func, timeout = 100) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            func.apply(this, args);
        }, timeout);
    };
}