type CompareFn = (valueA: unknown, valueB: unknown) => number;
type OrderEnum = 'asc' | 'desc';
type Order = OrderEnum | CompareFn;
type CompareOptions = {
    order?: OrderEnum;
    locale?: Locale;
} | OrderEnum | undefined;
type Locale = string;
type IdentifierFn<T> = (value: T) => unknown;
type Identifier<T> = IdentifierFn<T> | keyof T | number;

/**
 * Creates a compare function that defines the natural sort order considering
 * the given `options` which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).
 */
declare function compare(options?: CompareOptions): CompareFn;

/**
 * Creates an array of elements, natural sorted by specified identifiers and
 * the corresponding sort orders. This method implements a stable sort
 * algorithm, which means the original sort order of equal elements is
 * preserved.
 */
declare function orderBy<T>(collection: ReadonlyArray<T>, identifiers?: ReadonlyArray<Identifier<T>> | Identifier<T> | null, orders?: ReadonlyArray<Order> | Order | null, locale?: Locale): Array<T>;

export { type CompareFn, type CompareOptions, type Identifier, type Order, compare, orderBy };
