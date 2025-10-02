declare global {
  interface Window {
    __patrol_listDartTests: () => string;
    __patrol_runDartTestWithCallback: (
      name: string,
      callback: (result: string) => void
    ) => void;
    __patrol_setInitialised: () => void;
  }
}

export type PatrolTestEntry = {
  name: string;
  skip: boolean;
  tags: string[];
};

export type PatrolTestResult = {
  result: "success" | "failure";
  details: string | null;
};
