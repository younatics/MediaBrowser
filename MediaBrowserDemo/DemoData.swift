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
    class func singlePhoto() -> [Media] {
        let photo = localMediaPhoto(imageName: "MotionBookIcon", caption: "MotionBookIcon")
        
        return [photo]
    }
    
    class func multiplePhotoAndVideo() -> [Media] {
        var photos = [Media]()
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
    
    class func multiplePhotoGrid() -> [Media] {
        var photos = [Media]()

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
    
    class func photoSelection() -> [Media] {
        var photos = [Media]()
        
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
    
    class func webPhotos() -> [Media] {
        var photos = [Media]()
        
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
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/02/09/18/40/robbe-2053165_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/03/27/21/31/money-2180330_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/01/20/15/12/orange-1995079_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/03/07/13/02/thought-2123970_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2014/02/23/09/17/thinking-272677_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/05/15/17/43/cup-2315563_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/08/02/14/26/winter-landscape-2571788_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/01/05/11/16/icicle-1954827_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2014/12/13/15/42/alaska-566722_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2013/02/13/12/06/greenland-81241_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/01/08/13/51/greenland-1963003_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2016/07/30/16/17/skull-1557446_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/03/15/21/16/checkmated-2147538_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/03/04/14/19/helicopter-2116170_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/02/11/10/33/spaceship-2057420_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/03/13/21/09/ring-of-fire-2141192_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2012/04/13/20/40/ring-33573_1280.png", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/02/02/22/08/tunnel-2033983_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2017/02/04/12/51/labyrinth-2037286_1280.jpg", caption: nil)
        photos.append(photo)
        
        photo = webMediaPhoto(url: "https://cdn.pixabay.com/photo/2016/12/20/22/47/harley-1921700_1280.jpg", caption: nil)
        photos.append(photo)

        return photos
    }
    
    class func singleVideo() -> [Media] {
        var photos = [Media]()

        let photo = localMediaPhoto(imageName: "Atoms_thumb", caption: "Atom")
        photo.videoURL = URL(fileURLWithPath: Bundle.main.path(forResource: "Atoms", ofType: "mp4")!)
        photos.append(photo)
        
        return photos

    }
    
    class func multiVideos() -> [Media] {
        var photos = [Media]()
        
        var photo = webMediaVideo(url: "https://player.vimeo.com/external/199627560.sd.mp4?s=4d51ea25ca083b46834911fc794db2e99e6075c7&profile_id=165", previewImageURL: "https://i.vimeocdn.com/video/612917789_640x360.jpg")
        photos.append(photo)
        
        photo = webMediaVideo(url: "https://player.vimeo.com/external/199224619.sd.mp4?s=801da27765a835ea41aa8b957553287d12661142&profile_id=165", previewImageURL: "https://i.vimeocdn.com/video/612415426_640x360.jpg")
        photos.append(photo)

        photo = webMediaVideo(url: "https://player.vimeo.com/external/220312371.sd.mp4?s=67b5f45dfcc1a4e59a6e6739c34551e69a70844d&profile_id=165", previewImageURL: "https://i.vimeocdn.com/video/638284371_640x360.jpg")
        photos.append(photo)


        return photos
    }
    
    class func multiVideoThumbs() -> [Media] {
        var thumbs = [Media]()
        
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

    
    class func localMediaPhoto(imageName: String, caption: String) -> Media {
        guard let image = UIImage(named: imageName) else {
            fatalError("Image is nil")
        }
        
        let photo = Media(image: image, caption: caption)
        return photo
    }
    
    class func webMediaPhoto(url: String, caption: String?) -> Media {
        guard let validUrl = URL(string: url) else {
            fatalError("Image is nil")
        }
        
        var photo = Media()
        if let _caption = caption {
            photo = Media(url: validUrl, caption: _caption)
        } else {
            photo = Media(url: validUrl)
        }
        return photo
    }
    
    class func webMediaVideo(url: String, previewImageURL: String? = nil) -> Media {
        guard let validUrl = URL(string: url) else {
            fatalError("Video is nil")
        }

        let photo = Media(videoURL: validUrl, previewImageURL: URL(string: previewImageURL ?? ""))
        return photo
    }
}
