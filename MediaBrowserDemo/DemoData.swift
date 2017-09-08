//
//  DemoData.swift
//  MediaBrowser
//
//  Created by Seungyoun Yi on 2017. 9. 8..
//  Copyright © 2017년 Seungyoun Yi. All rights reserved.
//

import Foundation
import MediaBrowser

class DemoData {
    class func singlePhoto() -> [MWPhoto] {
        let photo = localMediaPhoto(imageName: "MotionBookIcon", caption: "MotionBookIcon")
        
        return [photo]
    }
    
    class func multiplePhotoAndVideo() -> [MWPhoto] {
        var photos = [MWPhoto]()
        var photo = localMediaPhoto(imageName: "MotionBookIntro1", caption: "MotionBook Intro 1")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro2", caption: "MotionBook Intro 2")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "Atoms_thumb", caption: "Atom")
        photo.videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Atoms", ofType: "mp4")!)
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro3", caption: "MotionBook Intro 3")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro4", caption: "MotionBook Intro 4")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro5", caption: "MotionBook Intro 5")
        photos.append(photo)
        
        return photos
    }
    
    class func multiplePhotoGrid() -> [MWPhoto] {
        var photos = [MWPhoto]()

        var photo = localMediaPhoto(imageName: "MotionBookIntro1", caption: "MotionBook Intro 1")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro2", caption: "MotionBook Intro 2")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro3", caption: "MotionBook Intro 3")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro4", caption: "MotionBook Intro 4")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "MotionBookIntro5", caption: "MotionBook Intro 5")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo1", caption: "Demo Image 1 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo2", caption: "Demo Image 2 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo3", caption: "Demo Image 3 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo4", caption: "Demo Image 4 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo5", caption: "Demo Image 5 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo6", caption: "Demo Image 6 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo7", caption: "Demo Image 7 from Pixabay")
        photos.append(photo)
        
        return photos
    }
    
    class func photoSelection() -> [MWPhoto] {
        var photos = [MWPhoto]()
        
        var photo = localMediaPhoto(imageName: "demo1", caption: "Demo Image 1 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo2", caption: "Demo Image 2 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo3", caption: "Demo Image 3 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo4", caption: "Demo Image 4 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo5", caption: "Demo Image 5 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo6", caption: "Demo Image 6 from Pixabay")
        photos.append(photo)
        
        photo = localMediaPhoto(imageName: "demo7", caption: "Demo Image 7 from Pixabay")
        photos.append(photo)
        
        return photos

    }
    
    class func webPhotos() -> [MWPhoto] {
        var photos = [MWPhoto]()
        
        var photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/03/11/22/laptop-2575689_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/05/22/43/sticky-2586309_1280.jpg", caption: nil)
        photos.append(photo)

        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/07/26/11/18/coffee-2541286_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/01/01/16/computer-2562560_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/01/00/00/peopl-2562135_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/06/10/19/people-2590997_1280.jpg", caption: nil)
        photos.append(photo)

        return photos
    }
    
    class func singleVideo() -> [MWPhoto] {
        var photos = [MWPhoto]()

        let photo = localMediaPhoto(imageName: "Atoms_thumb", caption: "Atom")
        photo.videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Atoms", ofType: "mp4")!)
        photos.append(photo)
        
        return photos

    }
    
    class func multiVideos() -> [MWPhoto] {
        var photos = [MWPhoto]()
        
        var photo = webMediaVideo(url: "https://player.vimeo.com/external/199627560.sd.mp4?s=4d51ea25ca083b46834911fc794db2e99e6075c7&profile_id=165")
        photos.append(photo)
        
        photo = webMediaVideo(url: "https://player.vimeo.com/external/199224619.sd.mp4?s=801da27765a835ea41aa8b957553287d12661142&profile_id=165")
        photos.append(photo)
        
        photo = webMediaVideo(url: "https://player.vimeo.com/external/220312371.sd.mp4?s=67b5f45dfcc1a4e59a6e6739c34551e69a70844d&profile_id=165")
        photos.append(photo)


        return photos
    }
    
    class func multiVideoThumbs() -> [MWPhoto] {
        var thumbs = [MWPhoto]()
        
        var thumb = webMediaPhoto(url: "https://i.vimeocdn.com/video/612917789_640x360.jpg", caption: nil)
        thumb.isVideo = true
        thumbs.append(thumb)
        
        thumb = webMediaPhoto(url: "https://i.vimeocdn.com/video/612415426_640x360.jpg", caption: nil)
        thumb.isVideo = true
        thumbs.append(thumb)
        
        thumb = webMediaPhoto(url: "https://i.vimeocdn.com/video/638284371_640x360.jpg", caption: nil)
        thumb.isVideo = true
        thumbs.append(thumb)

        return thumbs
    }

    
    class func localMediaPhoto(imageName: String, caption: String) -> MWPhoto {
        guard let image = UIImage(named: imageName) else {
            fatalError("Image is nil")
        }
        
        let photo = MWPhoto(image: image, caption: caption)
        return photo
    }
    
    class func webMediaPhoto(url: String, caption: String?) -> MWPhoto {
        guard let validUrl = URL(string: url) else {
            fatalError("Image is nil")
        }
        
        var photo = MWPhoto()
        if let _caption = caption {
            photo = MWPhoto(url: validUrl, caption: _caption)
        } else {
            photo = MWPhoto(url: validUrl)
        }
        return photo
    }
    
    class func webMediaVideo(url: String) -> MWPhoto {
        guard let validUrl = URL(string: url) else {
            fatalError("Video is nil")
        }
        
        let photo = MWPhoto(videoURL: validUrl)
        return photo
    }
}
