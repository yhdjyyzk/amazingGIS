import type { App } from 'vue';
import { ElementPlus } from './elementui';

export function usePlugins(app: App<Element>) {
  app.use(ElementPlus)
}
