/*
 * Copyright (c) [2022] SUSE LLC
 *
 * All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of version 2 of the GNU General Public License as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, contact SUSE LLC.
 *
 * To contact SUSE LLC about this file by physical or electronic mail, you may
 * find current contact information at www.suse.com.
 */

import React, { useState } from "react";
import { useInstallerClient } from "./context/installer";
import { useSoftware } from "./context/software";
import { useNavigate } from "react-router-dom";

import { Button, Flex, FlexItem, Text } from "@patternfly/react-core";

import Layout from "./Layout";
import Category from "./Category";
import LanguageSelector from "./LanguageSelector";
import Storage from "./Storage";
import Users from "./Users";
import Popup from "./Popup";

import {
  EOS_SOFTWARE as OverviewIcon,
  EOS_TRANSLATE as LanguagesSelectionIcon,
  EOS_VOLUME as HardDriveIcon,
  EOS_MANAGE_ACCOUNTS as UsersIcon,
  EOS_MODE_EDIT as ModeEditIcon
} from "eos-icons-react";

const InstallButton = () => {
  const client = useInstallerClient();
  const [isOpen, setIsOpen] = useState(false);

  const open = () => setIsOpen(true);
  const close = () => setIsOpen(false);
  const install = () => client.manager.startInstallation();

  return (
    <>
      <Button isLarge variant="primary" onClick={open}>
        Install
      </Button>

      <Popup
        title="Confirm Installation"
        isOpen={isOpen}
      >
        <Text>
          If you continue, partitions on your hard disk will be modified according to the
          installation settings in the previous dialog.
        </Text>
        <Text>
          Please, cancel and check the settings if you are unsure.
        </Text>

        <Popup.Actions>
          <Popup.Confirm onClick={install}>Install</Popup.Confirm>
          <Popup.Cancel onClick={close} autoFocus />
        </Popup.Actions>
      </Popup>
    </>
  );
};

function Overview() {
  const { products, selectedProduct } = useSoftware();
  const navigate = useNavigate();

  const categories = [
    <Category key="language" title="Language" icon={LanguagesSelectionIcon}>
      <LanguageSelector />
    </Category>,
    <Category key="targer" title="Target" icon={HardDriveIcon}>
      <Storage />
    </Category>,
    <Category key="users" title="Users" icon={UsersIcon}>
      <Users />
    </Category>
  ];

  const renderCategories = () => {
    return categories.map(category => (
      <FlexItem key={category.props.title} className="installation-overview-section">
        {category}
      </FlexItem>
    ));
  };

  const RightActions = () => {
    if (products.length === 1) {
      return "";
    }

    return (
      <Button
        isSmall
        variant="plain"
        icon={<ModeEditIcon />}
        aria-label="Change selected product"
        onClick={() => navigate("products")}
      />
    );
  };

  return (
    <Layout
      sectionTitle={selectedProduct.name}
      SectionIcon={OverviewIcon}
      FooterActions={InstallButton}
      RightActions={RightActions}
    >
      <Flex direction={{ default: "column" }}>{renderCategories()}</Flex>
    </Layout>
  );
}

export default Overview;
