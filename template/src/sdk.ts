/**
 * PeekIt Plugin SDK
 * Официальный типизированный клиент связи для плагинов PeekIt
 */

export interface FileMetadata {
  filePath: string;
  fileName: string;
  fileSize: number;
  theme: 'dark' | 'light';
}

export type ThemeChangeListener = (theme: 'dark' | 'light') => void;
export type InitListener = (meta: FileMetadata) => void;

class PeekitPluginSDK {
  private initListeners: InitListener[] = [];
  private themeListeners: ThemeChangeListener[] = [];
  private currentMetadata: FileMetadata | null = null;
  private isInsideHost = window.self !== window.top;

  constructor() {
    window.addEventListener('message', this.handleMessage.bind(this));
  }

  /**
   * Уведомить хост о готовности плагина принимать метаданные
   */
  public ready(): void {
    if (this.isInsideHost) {
      window.parent.postMessage({ type: 'PEEKIT_READY' }, '*');
    } else {
      // Mock окружение для разработки в обычном браузере
      console.info('[PeekIt Mock] Running outside host. Providing mock metadata...');
      setTimeout(() => {
        const mock: FileMetadata = {
          filePath: 'C:\\Users\\Kobalt\\Documents\\SampleFile.sample',
          fileName: 'SampleFile.sample',
          fileSize: 1048576,
          theme: 'dark'
        };
        this.triggerInit(mock);
      }, 300);
    }
  }

  /**
   * Запросить бинарное содержимое файла у хоста
   */
  public requestData(): Promise<ArrayBuffer> {
    if (!this.isInsideHost) {
      // Mock данные для dev режима
      return Promise.resolve(new TextEncoder().encode('Mock File Content for development').buffer);
    }

    return new Promise((resolve) => {
      const handler = (event: MessageEvent) => {
        if (event.data?.type === 'PEEKIT_DATA_RESPONSE' && event.data.payload instanceof ArrayBuffer) {
          window.removeEventListener('message', handler);
          resolve(event.data.payload);
        }
      };
      window.addEventListener('message', handler);
      window.parent.postMessage({ type: 'PEEKIT_REQUEST_DATA' }, '*');
    });
  }

  /**
   * Запросить адаптацию размера окна PeekIt под контент плагина
   */
  public resize(width: number, height: number): void {
    if (this.isInsideHost) {
      window.parent.postMessage({ type: 'PEEKIT_RESIZE', payload: { width, height } }, '*');
    }
  }

  public onInit(callback: InitListener): void {
    if (this.currentMetadata) {
      callback(this.currentMetadata);
    }
    this.initListeners.push(callback);
  }

  public onThemeChange(callback: ThemeChangeListener): void {
    this.themeListeners.push(callback);
  }

  private handleMessage(event: MessageEvent): void {
    const data = event.data;
    if (!data || typeof data !== 'object') return;

    if (data.type === 'PEEKIT_INIT' && data.payload) {
      this.triggerInit(data.payload as FileMetadata);
    } else if (data.type === 'PEEKIT_THEME_CHANGED' && data.payload?.theme) {
      const theme = data.payload.theme;
      document.documentElement.setAttribute('data-theme', theme);
      for (const listener of this.themeListeners) {
        listener(theme);
      }
    }
  }

  private triggerInit(meta: FileMetadata): void {
    this.currentMetadata = meta;
    document.documentElement.setAttribute('data-theme', meta.theme);
    for (const listener of this.initListeners) {
      listener(meta);
    }
  }
}

export const peekit = new PeekitPluginSDK();
