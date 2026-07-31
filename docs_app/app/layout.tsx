import { config } from "@fortawesome/fontawesome-svg-core"
import { GoogleTagManager } from "@next/third-parties/google"
import { Banner } from "fumadocs-ui/components/banner"
import { RootProvider } from "fumadocs-ui/provider/next"
import { Inter } from "next/font/google"
import Script from "next/script"
import "./global.css"
import "@fortawesome/fontawesome-svg-core/styles.css"

config.autoAddCss = false

const inter = Inter({
  subsets: ["latin"],
})

const webinarUrl =
  "https://leancode.co/webinar/mastering-patrol-and-ai-next-level-e2e-testing?utm_source=patrol_page&utm_medium=yellow_banner&utm_campaign=webinar"

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <head>
        <Script src="//cdn.cookie-script.com/s/3aee4f412722d00911596bace9d15935.js" />
      </head>
      <body className="flex flex-col min-h-screen">
        <RootProvider>
          <Banner id="patrol-webinar-banner" className="patrol-docs-webinar-banner w-full">
            <span>
              Webinar: Mastering Patrol & AI: Next-Level E2E Testing.{" "}
              <a href={webinarUrl} className="font-bold underline underline-offset-2">
                Register now
              </a>
            </span>
          </Banner>
          {children}
        </RootProvider>
      </body>
      <GoogleTagManager gtmId="GTM-PBMQJ8GM" />
    </html>
  )
}
