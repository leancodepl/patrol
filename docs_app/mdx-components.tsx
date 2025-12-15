import defaultMdxComponents from "fumadocs-ui/mdx";
import type { MDXComponents } from "mdx/types";
import * as TabsComponents from "fumadocs-ui/components/tabs";
import { Accordion, Accordions } from "fumadocs-ui/components/accordion";
import { Step, Steps } from "fumadocs-ui/components/steps";
import { Callout } from "fumadocs-ui/components/callout";
import { Tweet, YouTube } from "@/components/Embed";

export function getMDXComponents(components?: MDXComponents): MDXComponents {
  return {
    ...defaultMdxComponents,
    ...TabsComponents,
    ...components,
    Error: (props) => <Callout {...props} type="error" />,
    Info: (props) => <Callout {...props} type="info" />,
    Warning: (props) => <Callout {...props} type="warning" />,
    Success: (props) => <Callout {...props} type="success" />,
    Step,
    Steps,
    YouTube,
    Tweet,
    Accordions,
    Accordion,
  };
}
