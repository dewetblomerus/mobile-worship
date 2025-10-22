# User Journey

## User Journey Map

```mermaid
journey
    title Mobile Worship User Journey
    section First Time User
      Visit app: User
      Sign up with Auth0: User, Auth0
      Auto-create Personal org: Accounts, Organizations
      Redirect to dashboard: User
    section Managing Songs
      View songs list: User
      Create new song: User, Content
      Edit song parts/slides: User, Content
      Delete song: User, Content
    section Managing Sets
      View sets list: User
      Create new set: User, Content
      Add songs to set: User, Content
      Reorder songs in set: User, Content
      Remove song from set: User, Content
    section Presenting
      Open set for presentation: Presenter, Content
      Share link with viewers: Presenter
      Navigate through slides: Presenter
    section Viewing (No Sign-in Required)
      Open shared link: Viewer
      View current slide: Viewer
      Auto-update as presenter advances: Viewer
```

---

## Journey Notes

- **Actors**: Show which systems/contexts are involved in each step
- **First Time Experience**: Seamless onboarding with automatic Personal organization creation
- **Core Workflows**: Song and Set management are the primary user activities
- **Presentation Flow**: Presenter controls slides and shares a link with viewers
- **Viewing Experience**: No sign-in required for viewers; slides auto-update via WebSocket
- **End Goal**: Presenting worship content with synchronized viewing across multiple devices
