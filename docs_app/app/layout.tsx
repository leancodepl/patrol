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

const patrolBannerRainbowColors = [
  "rgba(240, 255, 0, 0.45)",
  "rgba(255, 160, 63, 0.55)",
  "transparent",
  "rgba(255, 160, 63, 0.55)",
  "rgba(240, 255, 0, 0.45)",
  "transparent",
  "rgba(255, 160, 63, 0.55)",
]

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <head>
        <Script src="//cdn.cookie-script.com/s/3aee4f412722d00911596bace9d15935.js" />
      </head>
      <body className="flex flex-col min-h-screen">
        <RootProvider>
          <Banner
            id="patrol-best-e2e-framework-banner"
            variant="rainbow"
            rainbowColors={patrolBannerRainbowColors}
            className="font-medium">
            Patrol is the best e2e testing framework ever
          </Banner>
          {children}
        </RootProvider>
      </body>
      <GoogleTagManager gtmId="GTM-PBMQJ8GM" />
    </html>
  )
}
