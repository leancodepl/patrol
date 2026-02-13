import { docs } from "@/.source"
import { fab, faDiscord, faXTwitter } from "@fortawesome/free-brands-svg-icons"
import { faCode, fas } from "@fortawesome/free-solid-svg-icons"
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome"
import { type InferPageType, loader, LoaderPlugin, PageTreeTransformer } from "fumadocs-core/source"

const commonLinks = [
  {
    type: "page" as const,
    name: "Follow us on X!",
    url: "https://x.com/patrol_leancode",
    external: true,
    icon: <FontAwesomeIcon icon={faXTwitter} />,
  },
  {
    type: "page" as const,
    name: "Discord",
    url: "https://discord.gg/ukBK5t4EZg",
    external: true,
    icon: <FontAwesomeIcon icon={faDiscord} />,
  },
  {
    type: "page" as const,
    name: "patrol API reference",
    url: "https://pub.dev/documentation/patrol/latest/index.html",
    external: true,
    icon: <FontAwesomeIcon icon={faCode} />,
  },
  {
    type: "page" as const,
    name: "patrol_finders API reference",
    url: "https://pub.dev/documentation/patrol_finders/latest/index.html",
    external: true,
    icon: <FontAwesomeIcon icon={faCode} />,
  },
]

// See https://fumadocs.dev/docs/headless/source-api for more info
export const source = loader({
  baseUrl: "/",
  source: docs.toFumadocsSource(),
  plugins: [fontAwesomeIconsPlugin(), sharedLinksPlugin()],
})

export function getPageImage(page: InferPageType<typeof source>) {
  const segments = [...page.slugs, "image.png"]

  return {
    segments,
    url: `/og/${segments.join("/")}`,
  }
}

export async function getLLMText(page: InferPageType<typeof source>) {
  const processed = await page.data.getText("processed")

  return `# ${page.data.title}

${processed}`
}

type GetNodeType<T extends "file" | "folder" | "separator"> = Parameters<Exclude<PageTreeTransformer[T], undefined>>[0]

type Item = GetNodeType<"file">
type Folder = GetNodeType<"folder">
type Separator = GetNodeType<"separator">

function fontAwesomeIconsPlugin(): LoaderPlugin {
  const icons = { ...fas, ...fab }

  function replaceIcon<T extends Folder | Item | Separator>(node: T) {
    if (typeof node.icon === "string") {
      const possibleFaIconName = `fa${node.icon}`
      if (possibleFaIconName in icons) {
        node.icon = <FontAwesomeIcon icon={icons[possibleFaIconName]} />
      }
    }
    return node
  }

  return {
    name: "fumadocs:icon",
    transformPageTree: {
      file: replaceIcon,
      folder: replaceIcon,
      separator: replaceIcon,
    },
  }
}

function sharedLinksPlugin(): LoaderPlugin {
  return {
    name: "fumadocs:shared-links",
    transformPageTree: {
      folder: folder => {
        if (folder.root) {
          folder.children = [...commonLinks, ...folder.children]
        }
        return folder
      },
    },
  }
}
