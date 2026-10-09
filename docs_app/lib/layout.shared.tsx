import patrolIcon from "assets/patrol_icon.svg"
import { DocsLayoutProps } from "fumadocs-ui/layouts/notebook"
import Image from "next/image"
import { GithubInfo } from "../components/GithubInfo"

export function baseOptions(): Partial<DocsLayoutProps> {
  return {
    nav: {
      title: (
        <div className="flex items-center gap-3">
          <Image src={patrolIcon} alt="Patrol Icon" height={28} />
          <span className="text-l font-bold">Patrol</span>
        </div>
      ),
      mode: "top",
    },
    tabMode: "navbar",
    sidebar: {
      tabs: [
        {
          title: "Get Started",
          url: "/get-started",
        },
        {
          title: "Guides",
          url: "/guides",
        },
        {
          title: "Reference",
          url: "/reference",
        },
        {
          title: "Support & Services",
          url: "/support",
        },
      ],
    },
    links: [
      {
        text: "API",
        url: "https://pub.dev/documentation/patrol/latest/index.html",
        external: true,
      },
      {
        type: "custom",
        children: <GithubInfo owner="leancodepl" repo="patrol" className="lg:-mx-2" />,
      },
    ],
  }
}
