declare global {
  interface Window {
    __patrol_listDartTests: () => string;
    __patrol_runDartTestWithCallback: (
      name: string,
      callback: (result: string) => void
    ) => void;
  }
}

export type PatrolTestEntry = {
  name: string;
  skip: boolean;
  tags: string[];
};
