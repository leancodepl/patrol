/**
 * This function is used to start a local registry for testing purposes.
 * @param localRegistryTarget the target to run to start the local registry e.g. workspace:local-registry
 * @param storage the storage location for the local registry
 * @param verbose whether to log verbose output
 * @param clearStorage whether to clear the verdaccio storage before running the registry
 * @param listenAddress the address that verdaccio should listen to (default to `localhost`)
 */
export declare function startLocalRegistry({ localRegistryTarget, storage, verbose, clearStorage, listenAddress, }: {
    localRegistryTarget: string;
    storage?: string;
    verbose?: boolean;
    clearStorage?: boolean;
    listenAddress?: string;
}): Promise<() => void>;
export default startLocalRegistry;
//# sourceMappingURL=start-local-registry.d.ts.map