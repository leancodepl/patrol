import { AssetGlob } from './assets';
import { FileEvent } from './copy-assets-handler';
import { ExecutorContext } from '@nx/devkit';
export interface CopyAssetsOptions {
    outputPath: string;
    assets: (string | AssetGlob)[];
    watch?: boolean | WatchMode;
    includeIgnoredAssetFiles?: boolean;
}
export interface CopyAssetsResult {
    success?: boolean;
    stop?: () => void;
}
export interface WatchMode {
    onCopy?: (events: FileEvent[]) => void;
}
export declare function copyAssets(options: CopyAssetsOptions, context: ExecutorContext): Promise<CopyAssetsResult>;
//# sourceMappingURL=index.d.ts.map