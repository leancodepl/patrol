/**
 * natural-orderby v5.0.0
 *
 * Copyright (c) Olaf Ennen
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE.md file in the root directory of this source tree.
 *
 * @license MIT
 */
const compareNumbers = (numberA, numberB) => {
  if (numberA < numberB) {
    return -1;
  }
  if (numberA > numberB) {
    return 1;
  }
  return 0;
};

const compareUnicode = (stringA, stringB, locale) => {
  const result = stringA.localeCompare(stringB, locale);
  return result ? result / Math.abs(result) : 0;
};

const RE_NUMBERS = /(^0x[\da-fA-F]+$|^([+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?(?!\.\d+)(?=\D|\s|$))|\d+)/g;
const RE_LEADING_OR_TRAILING_WHITESPACES = /^\s+|\s+$/g; // trim pre-post whitespace
const RE_WHITESPACES = /\s+/g; // normalize all whitespace to single ' ' character
const RE_INT_OR_FLOAT = /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$/; // identify integers and floats
const RE_DATE = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[/-]\d{1,4}[/-]\d{1,4}|^\w+, \w+ \d+, \d{4})/; // identify date strings
const RE_LEADING_ZERO = /^0+[1-9]{1}[0-9]*$/;
// eslint-disable-next-line no-control-regex
const RE_UNICODE_CHARACTERS = /[^\x00-\x80]/;

const stringCompare = (stringA, stringB) => {
  if (stringA < stringB) {
    return -1;
  }
  if (stringA > stringB) {
    return 1;
  }
  return 0;
};

const compareChunks = (chunksA, chunksB, locale) => {
  const lengthA = chunksA.length;
  const lengthB = chunksB.length;
  const size = Math.min(lengthA, lengthB);
  for (let i = 0; i < size; i++) {
    const chunkA = chunksA[i];
    const chunkB = chunksB[i];
    if (chunkA.normalizedString !== chunkB.normalizedString) {
      if (chunkA.normalizedString === '' !== (chunkB.normalizedString === '')) {
        // empty strings have lowest value
        return chunkA.normalizedString === '' ? -1 : 1;
      }
      if (chunkA.parsedNumber !== undefined && chunkB.parsedNumber !== undefined) {
        // compare numbers
        const result = compareNumbers(chunkA.parsedNumber, chunkB.parsedNumber);
        if (result === 0) {
          // compare string value, if parsed numbers are equal
          // Example:
          // chunkA = { parsedNumber: 1, normalizedString: "001" }
          // chunkB = { parsedNumber: 1, normalizedString: "01" }
          // chunkA.parsedNumber === chunkB.parsedNumber
          // chunkA.normalizedString < chunkB.normalizedString
          return stringCompare(chunkA.normalizedString, chunkB.normalizedString);
        }
        return result;
      } else if (chunkA.parsedNumber !== undefined || chunkB.parsedNumber !== undefined) {
        // number < string
        return chunkA.parsedNumber !== undefined ? -1 : 1;
      } else if (RE_UNICODE_CHARACTERS.test(chunkA.normalizedString + chunkB.normalizedString)) {
        // use locale comparison only if one of the chunks contains unicode characters
        return compareUnicode(chunkA.normalizedString, chunkB.normalizedString, locale);
      } else {
        // use common string comparison for performance reason
        return stringCompare(chunkA.normalizedString, chunkB.normalizedString);
      }
    }
  }
  // if the chunks are equal so far, the one which has more chunks is greater than the other one
  if (lengthA > size || lengthB > size) {
    return lengthA <= size ? -1 : 1;
  }
  return 0;
};

const compareOtherTypes = (valueA, valueB) => {
  if (!valueA.chunks ? valueB.chunks : !valueB.chunks) {
    return !valueA.chunks ? 1 : -1;
  }
  if (valueA.isNaN ? !valueB.isNaN : valueB.isNaN) {
    return valueA.isNaN ? -1 : 1;
  }
  if (valueA.isSymbol ? !valueB.isSymbol : valueB.isSymbol) {
    return valueA.isSymbol ? -1 : 1;
  }
  if (valueA.isObject ? !valueB.isObject : valueB.isObject) {
    return valueA.isObject ? -1 : 1;
  }
  if (valueA.isArray ? !valueB.isArray : valueB.isArray) {
    return valueA.isArray ? -1 : 1;
  }
  if (valueA.isFunction ? !valueB.isFunction : valueB.isFunction) {
    return valueA.isFunction ? -1 : 1;
  }
  if (valueA.isNull ? !valueB.isNull : valueB.isNull) {
    return valueA.isNull ? -1 : 1;
  }
  return 0;
};

const compareValues = (valueA, valueB, locale) => {
  if (valueA.value === valueB.value) {
    return 0;
  }
  if (valueA.parsedNumber !== undefined && valueB.parsedNumber !== undefined) {
    return compareNumbers(valueA.parsedNumber, valueB.parsedNumber);
  }
  if (valueA.chunks && valueB.chunks) {
    return compareChunks(valueA.chunks, valueB.chunks, locale);
  }
  return compareOtherTypes(valueA, valueB);
};

const normalizeAlphaChunk = chunk => {
  return chunk.replace(RE_WHITESPACES, ' ').replace(RE_LEADING_OR_TRAILING_WHITESPACES, '');
};

const parseNumber = value => {
  if (value.length !== 0) {
    const parsedNumber = Number(value.replace(/_/g, ''));
    if (!Number.isNaN(parsedNumber)) {
      return parsedNumber;
    }
  }
  return undefined;
};

const normalizeNumericChunk = (chunk, index, chunks) => {
  if (RE_INT_OR_FLOAT.test(chunk)) {
    // don´t parse a number, if there´s a preceding decimal point
    // to keep significance
    // e.g. 1.0020, 1.020
    if (!RE_LEADING_ZERO.test(chunk) || index === 0 || chunks[index - 1] !== '.') {
      return parseNumber(chunk) || 0;
    }
  }
  return undefined;
};

const createChunkMap = (chunk, index, chunks) => ({
  parsedNumber: normalizeNumericChunk(chunk, index, chunks),
  normalizedString: normalizeAlphaChunk(chunk)
});

const createChunks = value => value.replace(RE_NUMBERS, '\0$1\0').replace(/\0$/, '').replace(/^\0/, '').split('\0');

const createChunkMaps = value => {
  const chunksMaps = createChunks(value).map(createChunkMap);
  return chunksMaps;
};

const isFunction = value => typeof value === 'function';

const isNaN = value => Number.isNaN(value) || value instanceof Number && Number.isNaN(value.valueOf());

const isNull = value => value === null;

const isObject = value => value !== null && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Number) && !(value instanceof String) && !(value instanceof Boolean) && !(value instanceof Date);

const isSymbol = value => typeof value === 'symbol';

const isUndefined = value => value === undefined;

const parseDate = value => {
  try {
    const parsedDate = Date.parse(value);
    if (!Number.isNaN(parsedDate)) {
      if (RE_DATE.test(value)) {
        return parsedDate;
      }
    }
    return undefined;
  } catch {
    return undefined;
  }
};

const numberify = value => {
  const parsedNumber = parseNumber(value);
  if (parsedNumber !== undefined) {
    return parsedNumber;
  }
  return parseDate(value);
};

const stringify = value => {
  if (typeof value === 'boolean' || value instanceof Boolean) {
    return Number(value).toString();
  }
  if (typeof value === 'number' || value instanceof Number) {
    return value.toString();
  }
  if (value instanceof Date) {
    return value.getTime().toString();
  }
  if (typeof value === 'string' || value instanceof String) {
    return value.toLowerCase().replace(RE_LEADING_OR_TRAILING_WHITESPACES, '');
  }
  return '';
};

const getMappedValueRecord = value => {
  if (typeof value === 'string' || value instanceof String || (typeof value === 'number' || value instanceof Number) && !isNaN(value) || typeof value === 'boolean' || value instanceof Boolean || value instanceof Date) {
    const stringValue = stringify(value);
    const parsedNumber = numberify(stringValue);
    const chunks = createChunkMaps(parsedNumber ? `${parsedNumber}` : stringValue);
    return {
      parsedNumber,
      chunks,
      value
    };
  }
  return {
    isArray: Array.isArray(value),
    isFunction: isFunction(value),
    isNaN: isNaN(value),
    isNull: isNull(value),
    isObject: isObject(value),
    isSymbol: isSymbol(value),
    isUndefined: isUndefined(value),
    value
  };
};

const baseCompare = options => (valueA, valueB) => {
  const a = getMappedValueRecord(valueA);
  const b = getMappedValueRecord(valueB);
  const result = compareValues(a, b, options.locale);
  return result * (options.order === 'desc' ? -1 : 1);
};

const isValidOrder = value => typeof value === 'string' && (value === 'asc' || value === 'desc');
const getOptions = customOptions => {
  let order = 'asc';
  let locale; // = 'en';
  if (typeof customOptions === 'string' && isValidOrder(customOptions)) {
    order = customOptions;
  } else if (customOptions && typeof customOptions === 'object') {
    if (customOptions.order && isValidOrder(customOptions.order)) {
      order = customOptions.order;
    }
    if (customOptions.locale && customOptions.locale.length > 0) {
      locale = customOptions.locale;
    }
  }
  return {
    order,
    locale
  };
};

/**
 * Creates a compare function that defines the natural sort order considering
 * the given `options` which may be passed to [`Array.prototype.sort()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort).
 */
function compare(options) {
  const validatedOptions = getOptions(options);
  return baseCompare(validatedOptions);
}

const compareMultiple = (recordA, recordB, orders, locale) => {
  const {
    index: indexA,
    values: valuesA
  } = recordA;
  const {
    index: indexB,
    values: valuesB
  } = recordB;
  const {
    length
  } = valuesA;
  const ordersLength = orders.length;
  for (let i = 0; i < length; i++) {
    const order = i < ordersLength ? orders[i] : null;
    if (order && typeof order === 'function') {
      const result = order(valuesA[i].value, valuesB[i].value);
      if (result) {
        return result;
      }
    } else {
      const result = compareValues(valuesA[i], valuesB[i], locale);
      if (result) {
        return result * (order === 'desc' ? -1 : 1);
      }
    }
  }
  return indexA - indexB;
};

const createIdentifierFn = identifier => {
  if (typeof identifier === 'function') {
    // identifier is already a lookup function
    return identifier;
  }
  return value => {
    if (Array.isArray(value)) {
      const index = Number(identifier);
      if (Number.isInteger(index)) {
        return value[index];
      }
    } else if (value && typeof value === 'object') {
      const result = Object.getOwnPropertyDescriptor(value, identifier);
      return result?.value;
    }
    return value;
  };
};

const getElementByIndex = (collection, index) => collection[index];

const getValueByIdentifier = (value, getValue) => getValue(value);

const baseOrderBy = (collection, identifiers, orders, locale) => {
  const identifierFns = identifiers.length ? identifiers.map(createIdentifierFn) : [value => value];

  // temporary array holds elements with position and sort-values
  const mappedCollection = collection.map((element, index) => {
    const values = identifierFns.map(identifier => getValueByIdentifier(element, identifier)).map(getMappedValueRecord);
    return {
      index,
      values
    };
  });

  // iterate over values and compare values until a != b or last value reached
  mappedCollection.sort((recordA, recordB) => compareMultiple(recordA, recordB, orders, locale));
  return mappedCollection.map(element => getElementByIndex(collection, element.index));
};

const getIdentifiers = identifiers => {
  if (!identifiers) {
    return [];
  }
  const identifierList = !Array.isArray(identifiers) ? [identifiers] : [...identifiers];
  if (identifierList.some(identifier => typeof identifier !== 'string' && typeof identifier !== 'number' && typeof identifier !== 'function')) {
    return [];
  }
  return identifierList;
};

const getOrders = orders => {
  if (!orders) {
    return [];
  }
  const orderList = !Array.isArray(orders) ? [orders] : [...orders];
  if (orderList.some(order => order !== 'asc' && order !== 'desc' && typeof order !== 'function')) {
    return [];
  }
  return orderList;
};

/**
 * Creates an array of elements, natural sorted by specified identifiers and
 * the corresponding sort orders. This method implements a stable sort
 * algorithm, which means the original sort order of equal elements is
 * preserved.
 */
function orderBy(collection, identifiers, orders, locale) {
  if (!collection || !Array.isArray(collection)) {
    return [];
  }
  const validatedIdentifiers = getIdentifiers(identifiers);
  const validatedOrders = getOrders(orders);
  return baseOrderBy(collection, validatedIdentifiers, validatedOrders, locale);
}

export { compare, orderBy };
