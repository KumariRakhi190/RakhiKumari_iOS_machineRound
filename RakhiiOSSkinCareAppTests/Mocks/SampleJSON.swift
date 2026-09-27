//
//  SampleJSON.swift
//  RakhiiOSSkinCareAppTests
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

/// Trimmed copies of real responses from the live APIs.
enum SampleJSON {

    static let categories = """
    {
      "status": true,
      "message": "Successfully data",
      "data": [
        {
          "id": "1",
          "applicationid": "19",
          "category_name": "Face Wrinkles",
          "image": "https://mobilehubs.website/appmanagement123/assets/uploaded/category/15580135786625.jpg",
          "audio_file": "",
          "language": [
            { "language_name": "English", "name": "Face Wrinkles", "description": "Face Wrinkles\\r\\n\\r\\n" },
            { "language_name": "Hindi", "name": "चेहरे की झुर्रियाँ", "description": "<pre>चेहरे की झुर्रियाँ</pre>" },
            { "language_name": "French", "name": "", "description": "" },
            { "language_name": "arabic", "name": "تجاعيد الوجه", "description": "تجاعيد الوجه<br>" }
          ]
        },
        {
          "id": "2",
          "applicationid": "19",
          "category_name": "Acne (Pimples)",
          "image": "https://mobilehubs.website/appmanagement123/assets/uploaded/category/15580136215487.jpg",
          "audio_file": "",
          "language": [
            { "language_name": "English", "name": "", "description": "" }
          ]
        }
      ]
    }
    """

    static let emptyCategories = """
    { "status": true, "message": "Successfully data", "data": [] }
    """

    static let subcategories = """
    {
      "status": true,
      "message": "Successfully data",
      "data": [
        {
          "id": "1",
          "applicationid": "19",
          "categoryid": "1",
          "subcategory_name": "REMEDY",
          "image": "https://mobilehubs.website/appmanagement123/assets/uploaded/subcategory/15550459809467.jpg",
          "language": [
            {
              "language_name": "English",
              "name": "Coconut oil",
              "description": "<div><font face=\\"arial\\">Coconut oil fights free radicals &amp; reduces wrinkles.</font></div><ul><li><span>Cleanse your face.</span></li><li>Leave the oil on overnight.&nbsp;</li></ul><b>Note:</b> Repeat every night.<br><br><br>"
            },
            { "language_name": "French", "name": "", "description": "" }
          ]
        }
      ]
    }
    """
}
