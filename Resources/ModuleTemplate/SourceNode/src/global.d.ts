declare global {
  export interface ActionBeeMessageEvent {
    focusAppID?: string
    focusAppName?: string
    pasteboardContent: string
  }

  export type ActionBeeAction = 'none' | 'overwrite' | 'speak'
}
export {}
