export const sleep = (s: number) =>
  new Promise<null>(resolve => {
    setTimeout(() => resolve(null), s * 1000)
  })
