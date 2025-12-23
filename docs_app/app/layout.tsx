import { config } from "@fortawesome/fontawesome-svg-core"
import { GoogleTagManager } from "@next/third-parties/google"
import { RootProvider } from "fumadocs-ui/provider/next"
import { Inter } from "next/font/google"
import Script from "next/script"
import "./global.css"
import "@fortawesome/fontawesome-svg-core/styles.css"

config.autoAddCss = false

const inter = Inter({
  subsets: ["latin"],
})

export default function Layout({ children }: LayoutProps<"/">) {
  return (
    <html lang="en" className={inter.className} suppressHydrationWarning>
      <head>
        <Script src="//cdn.cookie-script.com/s/3aee4f412722d00911596bace9d15935.js"/>
      </head>
      <body className="flex flex-col min-h-screen">
        <RootProvider>{children}</RootProvider>
      </body>
      <GoogleTagManager gtmId="GTM-PBMQJ8GM" />
    </html>
  )
}
