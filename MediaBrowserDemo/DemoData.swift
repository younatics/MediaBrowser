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
    
    
    
    class func localMediaPhoto(imageName: String, caption: String) -> MWPhoto {
        guard let image = UIImage(named: imageName) else {
            fatalError("Image is nil")
        }
        
        let photo = MWPhoto(image: image, caption: caption)
        return photo
    }

}
