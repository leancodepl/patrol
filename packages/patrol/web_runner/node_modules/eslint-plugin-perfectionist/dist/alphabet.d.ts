/**
 * Manages a customizable alphabet for sorting operations.
 *
 * Provides methods to generate, modify, and sort alphabets based on various
 * criteria including Unicode ranges, case prioritization, and locale-specific
 * ordering. Used by the 'custom' sort type to define character precedence.
 *
 * The class supports:
 *
 * - Generating alphabets from strings or Unicode ranges
 * - Case prioritization and manipulation
 * - Character positioning and removal
 * - Multiple sorting strategies (natural, locale, char code).
 *
 * @example
 *   // Create a custom alphabet with specific character order
 *   const alphabet = Alphabet.generateFrom('aAbBcC')
 *     .prioritizeCase('uppercase')
 *     .getCharacters()
 *   // Returns: 'AaBbCc'
 */
export declare class Alphabet {
  private characters
  private constructor()
  /**
   * Generates an alphabet from the given characters.
   *
   * @param values - The characters to generate the alphabet from.
   * @returns - The wrapped alphabet.
   */
  static generateFrom(values: string[] | string): Alphabet
  /**
   * Generates an alphabet containing relevant characters from the Unicode
   * standard. Contains the Unicode planes 0 and 1.
   *
   * @returns - The generated alphabet.
   */
  static generateRecommendedAlphabet(): Alphabet
  /**
   * Generates an alphabet containing all characters from the Unicode standard
   * except for irrelevant Unicode planes. Contains the Unicode planes 0, 1, 2
   * and 3.
   *
   * @returns - The generated alphabet.
   */
  static generateCompleteAlphabet(): Alphabet
  private static getCharactersWithCase
  /**
   * Generates an alphabet containing relevant characters from the Unicode
   * standard.
   *
   * @param maxCodePoint - The maximum code point to generate the alphabet to.
   * @returns - The generated alphabet.
   */
  private static generateAlphabetToRange
  /**
   * For each character with a lower and upper case, permutes the two cases so
   * that the alphabet is ordered by the case priority entered.
   *
   * @example
   *   Alphabet.generateFrom('aAbBcdCD').prioritizeCase('uppercase') // Returns 'AaBbCDcd'.
   *
   * @param casePriority - The case to prioritize.
   * @returns - The same alphabet instance with the cases prioritized.
   */
  prioritizeCase(casePriority: 'lowercase' | 'uppercase'): this
  /**
   * Adds specific characters to the end of the alphabet.
   *
   * @example
   *   Alphabet.generateFrom('ab').pushCharacters('cd')
   *   // Returns 'abcd'
   *
   * @param values - The characters to push to the alphabet.
   * @returns - The same alphabet instance without the specified characters.
   */
  pushCharacters(values: string[] | string): this
  /**
   * Permutes characters with cases so that all characters with the entered
   * case are put before the other characters.
   *
   * @param caseToComeFirst - The case to put before the other characters.
   * @returns - The same alphabet instance with all characters with case
   *   before all the characters with the other case.
   */
  placeAllWithCaseBeforeAllWithOtherCase(
    caseToComeFirst: 'uppercase' | 'lowercase',
  ): this
  /**
   * Places a specific character right before another character in the
   * alphabet.
   *
   * @example
   *   Alphabet.generateFrom('ab-cd/').placeCharacterBefore({
   *     characterBefore: '/',
   *     characterAfter: '-',
   *   })
   *   // Returns 'ab/-cd'
   *
   * @param params - The parameters for the operation.
   * @param params.characterBefore - The character to come before
   *   characterAfter.
   * @param params.characterAfter - The target character.
   * @returns - The same alphabet instance with the specific character
   *   prioritized.
   */
  placeCharacterBefore({
    characterBefore,
    characterAfter,
  }: {
    characterBefore: string
    characterAfter: string
  }): this
  /**
   * Places a specific character right after another character in the
   * alphabet.
   *
   * @example
   *   Alphabet.generateFrom('ab-cd/').placeCharacterAfter({
   *     characterBefore: '/',
   *     characterAfter: '-',
   *   })
   *   // Returns 'abcd/-'
   *
   * @param params - The parameters for the operation.
   * @param params.characterBefore - The target character.
   * @param params.characterAfter - The character to come after
   *   characterBefore.
   * @returns - The same alphabet instance with the specific character
   *   prioritized.
   */
  placeCharacterAfter({
    characterBefore,
    characterAfter,
  }: {
    characterBefore: string
    characterAfter: string
  }): this
  /**
   * Removes specific characters from the alphabet by their range.
   *
   * @param range - The Unicode range to remove characters from.
   * @param range.start - The starting Unicode codepoint.
   * @param range.end - The ending Unicode codepoint.
   * @returns - The same alphabet instance without the characters from the
   *   specified range.
   */
  removeUnicodeRange({ start, end }: { start: number; end: number }): this
  /**
   * Sorts the alphabet by the sorting function provided.
   *
   * @param sortingFunction - The sorting function to use.
   * @returns - The same alphabet instance sorted by the sorting function
   *   provided.
   */
  sortBy(
    sortingFunction: (characterA: string, characterB: string) => number,
  ): this
  /**
   * Sorts the alphabet by the natural order of the characters using
   * `natural-orderby`.
   *
   * @param locale - The locale to use for sorting.
   * @returns - The same alphabet instance sorted by the natural order of the
   *   characters.
   */
  sortByNaturalSort(locale?: string): this
  /**
   * Removes specific characters from the alphabet.
   *
   * @example
   *   Alphabet.generateFrom('abcd').removeCharacters('dcc')
   *   // Returns 'ab'
   *
   * @param values - The characters to remove from the alphabet.
   * @returns - The same alphabet instance without the specified characters.
   */
  removeCharacters(values: string[] | string): this
  /**
   * Sorts the alphabet by the character code point.
   *
   * @returns - The same alphabet instance sorted by the character code point.
   */
  sortByCharCodeAt(): this
  /**
   * Sorts the alphabet by the locale order of the characters.
   *
   * @param locales - The locales to use for sorting.
   * @returns - The same alphabet instance sorted by the locale order of the
   *   characters.
   */
  sortByLocaleCompare(locales?: Intl.LocalesArgument): this
  /**
   * Retrieves the characters from the alphabet.
   *
   * @returns The characters from the alphabet.
   */
  getCharacters(): string
  private placeCharacterBeforeOrAfter
  private getCharactersWithCase
}

export {}
