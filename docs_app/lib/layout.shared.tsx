import { DocsLayoutProps } from "fumadocs-ui/layouts/notebook";
import Image from "next/image";
import patrolIcon from "assets/patrol_icon.svg";
import { GithubInfo } from "fumadocs-ui/components/github-info";

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
          title: "Overview",
          url: "/",
        },
        {
          title: "Documentation",
          url: "/documentation",
        },
        {
          title: "CLI commands",
          url: "/cli-commands",
        },
        {
          title: "Patrol Feature Guide",
          url: "/feature-guide",
        },
        {
          title: "Articles & Resources",
          url: "/articles",
        },
        {
          title: "Pricing",
          url: "/pricing",
        },
        {
          title: "Contact us",
          url: "/contact",
        },
      ],
    },
    links: [
      {
        type: "custom",
        children: (
          <GithubInfo owner="leancodepl" repo="patrol" className="lg:-mx-2" />
        ),
      },
    ],
  };
}
