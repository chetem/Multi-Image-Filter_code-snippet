//the output data from an AVCaptureVideoDataOutput instance
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
	//get pixel buffer output and create image from it
	CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
	CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
	
	float xTranslation = self.isRetinaDevice ? 1280.0 : 640.0;
	float yTranslation = self.isRetinaDevice ? 960.0 : 480.0;
	
	//rotate image preview accordingly
	if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		image = [image imageByApplyingTransform:CGAffineTransformMakeRotation(M_PI)];
		image = [image imageByApplyingTransform: CGAffineTransformMakeTranslation(xTranslation, yTranslation)];
	}else if(self.interfaceOrientation == UIInterfaceOrientationPortrait){
		image = [image imageByApplyingTransform: CGAffineTransformMakeRotation(-(M_PI/2))];
		image = [image imageByApplyingTransform: CGAffineTransformMakeTranslation(0.0, xTranslation)];
	}else if(self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
		image = [image imageByApplyingTransform: CGAffineTransformMakeRotation(M_PI/2)];
		image = [image imageByApplyingTransform: CGAffineTransformMakeTranslation(yTranslation, 0.0)];
	}
	
	//flip image horizontally for mirrored display
	image = [image imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(-1, 1), -image.extent.size.width, 0)];
	
	//get copy of image from pixel buffer output image
	CIImage *imageCopy = [image copy];
	
	
	//apply filter to image
	CIFilter *imageFilter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];	//or whatever filter you want
	
	//make sure a filter has been selected
	if(imageFilter != NULL){
		//apply filter to image
		[imageFilter setValue: image forKey:kCIInputImageKey];
		image = imageFilter.outputImage;
	}
	
	//get rect of original, filtered image to fill part of screen
	CGRect extent = CGRectMake(0.0, 0.0, self.filterXPointDivider, image.extent.size.height);
	
	//get rect of copied, unfiltered image to fill the rest of the screen
	CGRect extentCopy = CGRectMake(self.filterXPointDivider, 0, (image.extent.size.width - self.filterXPointDivider), image.extent.size.height);
	
	//draw original image onto screen in the rect just previously determined
	[self.coreImageContext drawImage:image inRect:extent fromRect: extent];
	
	//draw copied image onto screen in the rect just previously determined
	[self.coreImageContext drawImage:imageCopy inRect:extentCopy fromRect:extentCopy];

	//present the buffer
	[self.context presentRenderbuffer:GL_RENDERBUFFER];
}