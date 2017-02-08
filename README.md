# Playlist Cheetah

**Playlist Cheetah** allows users to create playlist simply by swiping left to add songs or swiping right to skip them. When the app opens it grabs the users music library which includes songs on their device and in their iCloud library. After playlists are created they're persisted to the user's device through Apple's Core Data library.

![Alt text](https://cloud.githubusercontent.com/assets/20712747/22717136/007bb9c2-ed5f-11e6-8552-e0678550fb28.jpg)

## Apple Music Search View

Uses the Itunes Api to allow users to search and add songs from Apple Music if they are a member.
![Alt text](https://cloud.githubusercontent.com/assets/20712747/22717138/007c0792-ed5f-11e6-80d7-ef3e7fec35a2.jpg)

## Playlist View
Shows the users persisted Playlist

![Alt text](https://cloud.githubusercontent.com/assets/20712747/22717137/007bf37e-ed5f-11e6-9967-1d9424e7e3c4.jpg)

## Song List View
songs that compose a playlist

![Alt text](https://cloud.githubusercontent.com/assets/20712747/22717135/007b4000-ed5f-11e6-9fdf-8b5d1138a4b2.jpg)

**Pressing Play** opens the playlist in the native music app.

## Requirements
* Run on physical device Xcode throws weird errors when trying to run on simulator because it does not have the Native music app
* Some features require an Apple Music account

## Future Versions
* Spotify Support
* Machine learning to improve which song appears next
