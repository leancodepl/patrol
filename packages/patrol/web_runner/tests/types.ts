declare global {
  interface Window {
    __patrol_listDartTests?: () => string;
    __patrol_runDartTestWithCallback?: (
      name: string,
      callback: (result: string) => void
    ) => void;
    __patrol__onInitialised?: () => void;
    __patrol__isInitialised?: boolean;
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
