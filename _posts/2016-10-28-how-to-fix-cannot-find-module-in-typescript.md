---
layout: post
title: How to Fix "Cannot find module" in TypeScript
date: 2016-10-28
---

When using external library in TypeScript, one of the most common problem is that the `tsc` failed to find module. For example,

    12 import Image from 'react-native-image-progress';
                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    src/windows/main/pages/components/ProfilePicturePicker.tsx(12,19): error TS2307: Cannot find module 'react-native-image-progress'.

It is caused by missing typings definition. To search for any existing definition, just type this command in the project root:

    $ typings search react-native-image-progress
    No results found for search

It is very easy to fix if the typings is already in the typings registry. However in the above case no results are found. We then have to create the typing definition ourselves. It is rather easy but still take some time to do that.

# Step 1 - Create Typings Structure

First of all we create `typings/custom/react-native-image-progress` directory and `index.d.ts` file as shown below.

    SomeApp
    ├── typings
    │   └── custom
    │       └── react-native-image-progress
    │           └── index.d.ts
    └── typings.json

# Step 2 - Update the typing definition files

Add the following line to the `globalDependencies` in `typings.json`

    "react-native-image-progress": "file:typings/custom/react-native-image-progress/index.d.ts"

Add the following content to `typings/custom/react-native-image-progress/index.d.ts`

    declare module "react-native-image-progress" {
        import React, {ComponentClass} from 'react';
        import {ViewStyle, TextStyle} from 'react-native';

        interface IImageProgressProperties extends React.TouchableWithoutFeedbackProperties, React.Props<ImageProgressStatic> {
            indicator?: any;
            indicatorProps?: Object;
            renderIndicator?: any;
            threshold?: number;
            source: {uri: string} | string;
        }

        interface ImageProgressStatic extends ComponentClass<IImageProgressProperties> {
        }

        var ImageProgress: ImageProgressStatic;
        type ImageProgress = ImageProgressStatic;

        export = ImageProgress;

    }

# Step 3 - Install the custom typing definition

Run the following command

    typings install

After the above steps, you should now use the `*.ts` or `*.tsx` without any errors or warnings.
